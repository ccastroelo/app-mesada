import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../rules/rules.dart';
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
