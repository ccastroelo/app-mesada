import '../../../../core/error/result.dart';
import '../../../../core/storage/local_store.dart';
import '../../domain/entities/entry.dart';
import '../../domain/repositories/ledger_repository.dart';

/// Lançamentos guardados no aparelho (ADR-0014). Par filho × regra sem item na
/// lista = quantidade 0 e regra ativada (ADR-0013); o item nasce no primeiro
/// toque. [familyId] não é usado: no modo local existe uma família só.
class LedgerLocalRepository implements LedgerRepository {
  LedgerLocalRepository(this._store);

  final LocalStore _store;

  @override
  Stream<List<Entry>> watchEntries(String familyId) => _store.watch().map(
    (document) => [for (final map in document.entries) _toEntry(map)],
  );

  @override
  Future<Result<void>> increment(
    String familyId, {
    required String childId,
    required String ruleId,
  }) => _change(
    childId,
    ruleId,
    (map) => {...map, 'quantity': _quantity(map) + 1},
  );

  @override
  Future<Result<void>> decrement(
    String familyId, {
    required String childId,
    required String ruleId,
  }) => _change(childId, ruleId, (map) {
    final quantity = _quantity(map);
    return {...map, 'quantity': quantity == 0 ? 0 : quantity - 1};
  });

  @override
  Future<Result<void>> setEnabled(
    String familyId, {
    required String childId,
    required String ruleId,
    required bool enabled,
  }) => _change(childId, ruleId, (map) => {...map, 'enabled': enabled});

  @override
  Future<Result<void>> zero(String familyId, {String? childId}) {
    return _store.update(
      (document) => document.copyWith(
        entries: [
          for (final map in document.entries)
            if (childId == null || map['childId'] == childId)
              {...map, 'quantity': 0}
            else
              map,
        ],
      ),
    );
  }

  @override
  Future<Result<void>> restore(String familyId, Iterable<Entry> entries) {
    final quantityById = {
      for (final entry in entries) entry.id: entry.quantity,
    };
    return _store.update(
      (document) => document.copyWith(
        entries: [
          for (final map in document.entries)
            if (quantityById[_id(map)] case final quantity?)
              {...map, 'quantity': quantity}
            else
              map,
        ],
      ),
    );
  }

  /// Aplica [change] no par filho × regra, criando o item se ainda não existir.
  Future<Result<void>> _change(
    String childId,
    String ruleId,
    Map<String, dynamic> Function(Map<String, dynamic>) change,
  ) {
    final id = '${childId}_$ruleId';
    return _store.update((document) {
      final existing = document.entries.any((map) => _id(map) == id);
      return document.copyWith(
        entries: [
          for (final map in document.entries)
            if (_id(map) == id) change(map) else map,
          if (!existing)
            change({
              'childId': childId,
              'ruleId': ruleId,
              'quantity': 0,
              'enabled': true,
            }),
        ],
      );
    });
  }

  String _id(Map<String, dynamic> map) => '${map['childId']}_${map['ruleId']}';

  int _quantity(Map<String, dynamic> map) =>
      (map['quantity'] as num?)?.toInt() ?? 0;

  Entry _toEntry(Map<String, dynamic> map) {
    final quantity = _quantity(map);
    return Entry(
      childId: map['childId'] as String? ?? '',
      ruleId: map['ruleId'] as String? ?? '',
      // Arquivo é borda: um valor ruim não deve derrubar a tela.
      quantity: quantity < 0 ? 0 : quantity,
      enabled: map['enabled'] as bool? ?? true,
    );
  }
}
