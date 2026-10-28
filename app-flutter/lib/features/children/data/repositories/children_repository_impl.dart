import '../../../../core/error/result.dart';
import '../../../../core/firebase/firebase_failures.dart';
import '../../domain/entities/child.dart';
import '../../domain/repositories/children_repository.dart';
import '../datasources/children_firestore_datasource.dart';

class ChildrenRepositoryImpl implements ChildrenRepository {
  ChildrenRepositoryImpl(this._remote);

  final ChildrenFirestoreDataSource _remote;

  @override
  Stream<List<Child>> watchChildren(String familyId) => _remote
      .watchChildren(familyId)
      .map((dtos) => [for (final dto in dtos) dto.toEntity()]);

  @override
  Future<Result<String>> addChild(
    String familyId, {
    required String name,
    required String email,
    required int allowanceCents,
  }) async {
    try {
      final id = await _remote.addChild(
        familyId,
        name: name.trim(),
        email: email.trim(),
        allowanceCents: allowanceCents,
      );
      return Ok(id);
    } catch (error) {
      return Err(failureFromFirebase(error));
    }
  }

  @override
  Future<Result<void>> updateChild(String familyId, Child child) => _guard(
    () => _remote.updateChild(
      familyId,
      child.id,
      name: child.name.trim(),
      email: child.email.trim(),
      allowanceCents: child.allowanceCents,
    ),
  );

  @override
  Future<Result<void>> deleteChild(String familyId, String childId) =>
      _guard(() => _remote.deleteChild(familyId, childId));

  @override
  Future<Result<void>> reorder(String familyId, List<String> orderedIds) =>
      _guard(() => _remote.reorder(familyId, orderedIds));

  Future<Result<void>> _guard(Future<void> Function() action) async {
    try {
      await action();
      return const Ok(null);
    } catch (error) {
      return Err(failureFromFirebase(error));
    }
  }
}
