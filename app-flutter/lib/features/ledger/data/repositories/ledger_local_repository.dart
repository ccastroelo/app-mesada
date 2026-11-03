import '../../../../core/storage/local_store.dart';
import '../../domain/entities/entry.dart';
import '../../domain/repositories/ledger_repository.dart';

/// Lançamentos guardados no aparelho (ADR-0014). Par filho × regra sem item na
/// lista = quantidade 0 e regra ativada (ADR-0013); as escritas chegam no M4.
class LedgerLocalRepository implements LedgerRepository {
  LedgerLocalRepository(this._store);

  final LocalStore _store;

  @override
  Stream<List<Entry>> watchEntries(String familyId) => _store.watch().map(
    (document) => [for (final map in document.entries) _toEntry(map)],
  );

  Entry _toEntry(Map<String, dynamic> map) {
    final quantity = (map['quantity'] as num?)?.toInt() ?? 0;
    return Entry(
      childId: map['childId'] as String? ?? '',
      ruleId: map['ruleId'] as String? ?? '',
      // Arquivo é borda: um valor ruim não deve derrubar a tela.
      quantity: quantity < 0 ? 0 : quantity,
      enabled: map['enabled'] as bool? ?? true,
    );
  }
}
