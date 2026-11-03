import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/entry.dart';

/// Único ponto que fala com o Firestore para lançamentos.
/// Coleção: `families/{familyId}/entries/{childId}_{ruleId}` (ADR-0011).
class LedgerFirestoreDataSource {
  LedgerFirestoreDataSource(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _entries(String familyId) =>
      _db.collection('families/$familyId/entries');

  Stream<List<Entry>> watchEntries(String familyId) {
    return _entries(familyId).snapshots().map(
      (snapshot) => [for (final doc in snapshot.docs) _toEntry(doc.data())],
    );
  }

  /// Soma [by] na quantidade **no servidor**: dois responsáveis lançando ao
  /// mesmo tempo não perdem toque, e funciona offline (fila do SDK). O
  /// documento nasce aqui se faltar (ADR-0013); o piso 0 do − é garantido pela
  /// tela (botão desabilitado em 0) e pelas regras de segurança, que rejeitam
  /// quantidade negativa.
  Future<void> addQuantity(
    String familyId, {
    required String childId,
    required String ruleId,
    required int by,
  }) {
    return _entries(familyId).doc('${childId}_$ruleId').set({
      'childId': childId,
      'ruleId': ruleId,
      'quantity': FieldValue.increment(by),
    }, SetOptions(merge: true));
  }

  Future<void> setEnabled(
    String familyId, {
    required String childId,
    required String ruleId,
    required bool enabled,
  }) {
    return _entries(familyId).doc('${childId}_$ruleId').set({
      'childId': childId,
      'ruleId': ruleId,
      'enabled': enabled,
    }, SetOptions(merge: true));
  }

  /// Zera as quantidades de um filho, ou de todos se [childId] for nulo.
  Future<void> zero(String familyId, {String? childId}) async {
    final collection = _entries(familyId);
    final snapshot = await (childId == null
        ? collection.get()
        : collection.where('childId', isEqualTo: childId).get());
    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'quantity': 0});
    }
    await batch.commit();
  }

  /// Repõe quantidades exatas (Desfazer): aqui **não** cabe `increment`, o
  /// valor anterior é conhecido.
  Future<void> setQuantities(String familyId, Iterable<Entry> entries) {
    final batch = _db.batch();
    for (final entry in entries) {
      batch.set(_entries(familyId).doc(entry.id), {
        'childId': entry.childId,
        'ruleId': entry.ruleId,
        'quantity': entry.quantity,
      }, SetOptions(merge: true));
    }
    return batch.commit();
  }

  Entry _toEntry(Map<String, dynamic> data) {
    final quantity = (data['quantity'] as num?)?.toInt() ?? 0;
    return Entry(
      childId: data['childId'] as String,
      ruleId: data['ruleId'] as String,
      // As regras de segurança já impedem negativo; aqui só não deixar um dado
      // ruim derrubar a tela.
      quantity: quantity < 0 ? 0 : quantity,
      enabled: data['enabled'] as bool? ?? true,
    );
  }
}
