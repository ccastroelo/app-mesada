import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/child_dto.dart';

/// Único ponto que fala com o Firestore para filhos.
/// Coleção: `families/{familyId}/children/{id}` com `name`, `email`,
/// `allowanceCents` e `order` (ADR-0011, ADR-0013).
class ChildrenFirestoreDataSource {
  ChildrenFirestoreDataSource(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _children(String familyId) =>
      _db.collection('families/$familyId/children');

  Stream<List<ChildDto>> watchChildren(String familyId) {
    return _children(familyId)
        .orderBy('order')
        .snapshots()
        .map(
          (snapshot) => [
            for (final doc in snapshot.docs)
              ChildDto.fromMap(doc.id, doc.data()),
          ],
        );
  }

  /// Devolve o id do novo filho. `order` = relógio em milissegundos: entra no
  /// fim sem ler a lista (mesmo critério das regras, ADR-0013).
  Future<String> addChild(
    String familyId, {
    required String name,
    required String email,
    required int allowanceCents,
  }) async {
    final ref = _children(familyId).doc();
    await ref.set({
      'name': name,
      'email': email,
      'allowanceCents': allowanceCents,
      'order': DateTime.now().millisecondsSinceEpoch,
    });
    return ref.id;
  }

  Future<void> updateChild(
    String familyId,
    String childId, {
    required String name,
    required String email,
    required int allowanceCents,
  }) {
    return _children(familyId).doc(childId).update({
      'name': name,
      'email': email,
      'allowanceCents': allowanceCents,
    });
  }

  /// Apaga o filho e os lançamentos dele (`entries` com esse `childId`).
  Future<void> deleteChild(String familyId, String childId) async {
    final entries = await _db
        .collection('families/$familyId/entries')
        .where('childId', isEqualTo: childId)
        .get();
    final batch = _db.batch();
    for (final entry in entries.docs) {
      batch.delete(entry.reference);
    }
    batch.delete(_children(familyId).doc(childId));
    await batch.commit();
  }

  Future<void> reorder(String familyId, List<String> orderedIds) {
    final batch = _db.batch();
    for (var i = 0; i < orderedIds.length; i++) {
      batch.update(_children(familyId).doc(orderedIds[i]), {'order': i});
    }
    return batch.commit();
  }
}
