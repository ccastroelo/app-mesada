import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../rules/rules.dart';
import '../../domain/entities/family_snapshot.dart';
import '../models/family_dto.dart';
import '../models/invite_dto.dart';

/// Único ponto que fala com o Firestore para conta e família.
/// Estrutura e regras de segurança: ADR-0011 e `firestore.rules`.
class FamilyFirestoreDataSource {
  FamilyFirestoreDataSource(this._db);

  final FirebaseFirestore _db;

  Stream<String?> watchFamilyId(String uid) {
    return _db
        .doc('users/$uid')
        .snapshots()
        .map((snapshot) => snapshot.data()?['familyId'] as String?);
  }

  Stream<FamilyDto?> watchFamily(String familyId) {
    return _db.doc('families/$familyId').snapshots().map((snapshot) {
      final data = snapshot.data();
      return data == null ? null : FamilyDto.fromMap(snapshot.id, data);
    });
  }

  /// Lote 1: família, membro e vínculo do usuário. Lote 2: regras iniciais
  /// (só depois, porque as regras de segurança exigem já existir como membro).
  /// Cria a família já com o conteúdo **deste aparelho**, em vez das
  /// regras-padrão: é a virada de fonte de verdade do ADR-0014, que acontece
  /// uma vez, quando a pessoa escolhe compartilhar.
  ///
  /// Os ids locais são preservados, senão os lançamentos (`childId_ruleId`)
  /// apontariam para o vazio. Tudo num lote só — o pior caso aqui é umas
  /// centenas de documentos, bem abaixo do limite de 500 por lote.
  Future<void> createFamilyFromLocal({
    required String uid,
    required String email,
    required String name,
    required List<Map<String, dynamic>> children,
    required List<Map<String, dynamic>> rules,
    required List<Map<String, dynamic>> entries,
  }) async {
    final family = _db.collection('families').doc();
    final batch = _db.batch();
    batch.set(family, {
      'name': name,
      'createdBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(family.collection('members').doc(uid), {
      'email': email,
      'joinedAt': FieldValue.serverTimestamp(),
    });
    batch.set(_db.doc('users/$uid'), {'familyId': family.id});

    void copy(String collection, List<Map<String, dynamic>> items) {
      for (final item in items) {
        final id = item['id'] as String?;
        if (id == null) continue;
        batch.set(
          family.collection(collection).doc(id),
          {...item}..remove('id'),
        );
      }
    }

    copy('children', children);
    copy('rules', rules);
    for (final entry in entries) {
      final id = '${entry['childId']}_${entry['ruleId']}';
      batch.set(family.collection('entries').doc(id), entry);
    }
    await batch.commit();
  }

  /// Lê a família inteira (nome, filhos, regras e lançamentos) de uma vez.
  /// É o caminho de volta da virada do ADR-0014: o retrato que vira o arquivo
  /// local. Os ids dos documentos acompanham os dados, para os lançamentos
  /// (`childId_ruleId`) continuarem apontando para o lugar certo.
  Future<FamilySnapshot> fetchSnapshot(String familyId) async {
    final family = _db.doc('families/$familyId');
    final results = await Future.wait([
      family.get(),
      family.collection('children').get(),
      family.collection('rules').get(),
      family.collection('entries').get(),
    ]);
    final name = (results[0] as DocumentSnapshot<Map<String, dynamic>>)
        .data()?['name'];
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs(int index) =>
        (results[index] as QuerySnapshot<Map<String, dynamic>>).docs;
    return FamilySnapshot(
      name: name is String ? name : '',
      children: [
        for (final doc in docs(1)) {...doc.data(), 'id': doc.id},
      ],
      rules: [
        for (final doc in docs(2)) {...doc.data(), 'id': doc.id},
      ],
      entries: [for (final doc in docs(3)) doc.data()],
    );
  }

  Future<void> createFamily({
    required String uid,
    required String email,
    required String name,
    required List<RuleSeed> rules,
  }) async {
    final family = _db.collection('families').doc();

    final first = _db.batch();
    first.set(family, {
      'name': name,
      'createdBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
    first.set(family.collection('members').doc(uid), {
      'email': email,
      'joinedAt': FieldValue.serverTimestamp(),
    });
    first.set(_db.doc('users/$uid'), {'familyId': family.id});
    await first.commit();

    final second = _db.batch();
    for (var i = 0; i < rules.length; i++) {
      second.set(family.collection('rules').doc(), {
        'description': rules[i].description,
        'valueCents': rules[i].valueCents,
        'order': i,
      });
    }
    await second.commit();
  }

  /// Falha com `permission-denied` se o código já existir (colisão).
  Future<void> createInvite({
    required String code,
    required String familyId,
    required String uid,
    required DateTime expiresAt,
  }) {
    return _db.doc('invites/$code').set({
      'familyId': familyId,
      'createdBy': uid,
      'expiresAt': Timestamp.fromDate(expiresAt),
      'usedBy': null,
    });
  }

  Future<InviteDto?> getInvite(String code) async {
    final snapshot = await _db.doc('invites/$code').get();
    final data = snapshot.data();
    if (data == null) return null;
    return InviteDto(
      familyId: data['familyId'] as String,
      usedBy: data['usedBy'] as String?,
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
    );
  }

  /// Um único lote: membro (com o código), convite consumido e vínculo.
  Future<void> joinFamily({
    required String uid,
    required String email,
    required String code,
    required String familyId,
  }) {
    final batch = _db.batch();
    batch.set(_db.doc('families/$familyId/members/$uid'), {
      'email': email,
      'joinedAt': FieldValue.serverTimestamp(),
      'code': code,
    });
    batch.update(_db.doc('invites/$code'), {'usedBy': uid});
    batch.set(_db.doc('users/$uid'), {'familyId': familyId});
    return batch.commit();
  }
}
