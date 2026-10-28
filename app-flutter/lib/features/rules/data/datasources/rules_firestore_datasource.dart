import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/default_rules.dart';
import '../models/rule_dto.dart';

/// Único ponto que fala com o Firestore para regras.
/// Coleção: `families/{familyId}/rules/{id}` com `description`, `valueCents`
/// e `order` (ADR-0011).
class RulesFirestoreDataSource {
  RulesFirestoreDataSource(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _rules(String familyId) =>
      _db.collection('families/$familyId/rules');

  Stream<List<RuleDto>> watchRules(String familyId) {
    return _rules(familyId)
        .orderBy('order')
        .snapshots()
        .map(
          (snapshot) => [
            for (final doc in snapshot.docs)
              RuleDto.fromMap(doc.id, doc.data()),
          ],
        );
  }

  /// Regra nova entra no fim: `order` = relógio em milissegundos, sempre maior
  /// que os índices 0..n-1 gravados por [reorder] e pela semeadura, e sem
  /// precisar ler a lista antes (funciona offline).
  Future<void> addRule(
    String familyId, {
    required String description,
    required int valueCents,
  }) {
    return _rules(familyId).add({
      'description': description,
      'valueCents': valueCents,
      'order': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> updateRule(
    String familyId,
    String ruleId, {
    required String description,
    required int valueCents,
  }) {
    return _rules(familyId).doc(ruleId).update({
      'description': description,
      'valueCents': valueCents,
    });
  }

  /// Apaga a regra e os lançamentos dela (`entries` com esse `ruleId`).
  Future<void> deleteRule(String familyId, String ruleId) async {
    final entries = await _db
        .collection('families/$familyId/entries')
        .where('ruleId', isEqualTo: ruleId)
        .get();
    final batch = _db.batch();
    for (final entry in entries.docs) {
      batch.delete(entry.reference);
    }
    batch.delete(_rules(familyId).doc(ruleId));
    await batch.commit();
  }

  Future<void> reorder(String familyId, List<String> orderedIds) {
    final batch = _db.batch();
    for (var i = 0; i < orderedIds.length; i++) {
      batch.update(_rules(familyId).doc(orderedIds[i]), {'order': i});
    }
    return batch.commit();
  }

  Future<void> addSuggestions(String familyId, List<RuleSeed> seeds) {
    final base = DateTime.now().millisecondsSinceEpoch;
    final batch = _db.batch();
    for (var i = 0; i < seeds.length; i++) {
      batch.set(_rules(familyId).doc(), {
        'description': seeds[i].description,
        'valueCents': seeds[i].valueCents,
        'order': base + i,
      });
    }
    return batch.commit();
  }
}
