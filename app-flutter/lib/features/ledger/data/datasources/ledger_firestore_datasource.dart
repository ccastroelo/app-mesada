import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/entry.dart';

/// Único ponto que fala com o Firestore para lançamentos.
/// Coleção: `families/{familyId}/entries/{childId}_{ruleId}` (ADR-0011).
class LedgerFirestoreDataSource {
  LedgerFirestoreDataSource(this._db);

  final FirebaseFirestore _db;

  Stream<List<Entry>> watchEntries(String familyId) {
    return _db
        .collection('families/$familyId/entries')
        .snapshots()
        .map(
          (snapshot) => [for (final doc in snapshot.docs) _toEntry(doc.data())],
        );
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
