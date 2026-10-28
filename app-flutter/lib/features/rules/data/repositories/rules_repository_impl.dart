import '../../../../core/error/result.dart';
import '../../../../core/firebase/firebase_failures.dart';
import '../../domain/default_rules.dart';
import '../../domain/entities/rule.dart';
import '../../domain/repositories/rules_repository.dart';
import '../datasources/rules_firestore_datasource.dart';

class RulesRepositoryImpl implements RulesRepository {
  RulesRepositoryImpl(this._remote);

  final RulesFirestoreDataSource _remote;

  @override
  Stream<List<Rule>> watchRules(String familyId) => _remote
      .watchRules(familyId)
      .map((dtos) => [for (final dto in dtos) dto.toEntity()]);

  @override
  Future<Result<void>> addRule(
    String familyId, {
    required String description,
    required int valueCents,
  }) => _guard(
    () => _remote.addRule(
      familyId,
      description: description.trim(),
      valueCents: valueCents,
    ),
  );

  @override
  Future<Result<void>> updateRule(String familyId, Rule rule) => _guard(
    () => _remote.updateRule(
      familyId,
      rule.id,
      description: rule.description.trim(),
      valueCents: rule.valueCents,
    ),
  );

  @override
  Future<Result<void>> deleteRule(String familyId, String ruleId) =>
      _guard(() => _remote.deleteRule(familyId, ruleId));

  @override
  Future<Result<void>> reorder(String familyId, List<String> orderedIds) =>
      _guard(() => _remote.reorder(familyId, orderedIds));

  @override
  Future<Result<void>> addSuggestions(String familyId, List<RuleSeed> seeds) =>
      _guard(() => _remote.addSuggestions(familyId, seeds));

  Future<Result<void>> _guard(Future<void> Function() action) async {
    try {
      await action();
      return const Ok(null);
    } catch (error) {
      return Err(failureFromFirebase(error));
    }
  }
}
