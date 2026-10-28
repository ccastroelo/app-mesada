import '../../../../core/error/result.dart';
import '../default_rules.dart';
import '../entities/rule.dart';

/// Regras da família. A ordem da lista é a ordem de exibição em todo o app
/// (também a dos lançamentos de cada filho).
abstract class RulesRepository {
  Stream<List<Rule>> watchRules(String familyId);

  /// Entra no fim da lista.
  Future<Result<void>> addRule(
    String familyId, {
    required String description,
    required int valueCents,
  });

  Future<Result<void>> updateRule(String familyId, Rule rule);

  /// Apaga a regra e os lançamentos dela em todos os filhos.
  Future<Result<void>> deleteRule(String familyId, String ruleId);

  /// [orderedIds] é a nova ordem completa.
  Future<Result<void>> reorder(String familyId, List<String> orderedIds);

  /// Acrescenta [seeds] no fim da lista (as "sugestões").
  Future<Result<void>> addSuggestions(String familyId, List<RuleSeed> seeds);
}
