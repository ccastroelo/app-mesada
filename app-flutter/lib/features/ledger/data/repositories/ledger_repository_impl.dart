import '../../domain/entities/entry.dart';
import '../../domain/repositories/ledger_repository.dart';
import '../datasources/ledger_firestore_datasource.dart';

class LedgerRepositoryImpl implements LedgerRepository {
  LedgerRepositoryImpl(this._remote);

  final LedgerFirestoreDataSource _remote;

  @override
  Stream<List<Entry>> watchEntries(String familyId) =>
      _remote.watchEntries(familyId);
}
