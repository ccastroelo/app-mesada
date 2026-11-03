import '../../../../core/error/result.dart';
import '../../../../core/firebase/firebase_failures.dart';
import '../../domain/entities/entry.dart';
import '../../domain/repositories/ledger_repository.dart';
import '../datasources/ledger_firestore_datasource.dart';

class LedgerRepositoryImpl implements LedgerRepository {
  LedgerRepositoryImpl(this._remote);

  final LedgerFirestoreDataSource _remote;

  @override
  Stream<List<Entry>> watchEntries(String familyId) =>
      _remote.watchEntries(familyId);

  @override
  Future<Result<void>> increment(
    String familyId, {
    required String childId,
    required String ruleId,
  }) => _guard(
    () =>
        _remote.addQuantity(familyId, childId: childId, ruleId: ruleId, by: 1),
  );

  @override
  Future<Result<void>> decrement(
    String familyId, {
    required String childId,
    required String ruleId,
  }) => _guard(
    () =>
        _remote.addQuantity(familyId, childId: childId, ruleId: ruleId, by: -1),
  );

  @override
  Future<Result<void>> setEnabled(
    String familyId, {
    required String childId,
    required String ruleId,
    required bool enabled,
  }) => _guard(
    () => _remote.setEnabled(
      familyId,
      childId: childId,
      ruleId: ruleId,
      enabled: enabled,
    ),
  );

  @override
  Future<Result<void>> zero(String familyId, {String? childId}) =>
      _guard(() => _remote.zero(familyId, childId: childId));

  @override
  Future<Result<void>> restore(String familyId, Iterable<Entry> entries) =>
      _guard(() => _remote.setQuantities(familyId, entries));

  Future<Result<void>> _guard(Future<void> Function() action) async {
    try {
      await action();
      return const Ok(null);
    } catch (error) {
      return Err(failureFromFirebase(error));
    }
  }
}
