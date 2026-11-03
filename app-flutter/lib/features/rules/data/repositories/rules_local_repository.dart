import '../../../../core/error/result.dart';
import '../../../../core/storage/local_store.dart';
import '../../../../core/utils/local_id.dart';
import '../../domain/default_rules.dart';
import '../../domain/entities/rule.dart';
import '../../domain/repositories/rules_repository.dart';
import '../models/rule_dto.dart';

/// Regras guardadas no aparelho (ADR-0014). Mesmos campos do Firestore, então
/// o DTO é o mesmo; a ordenação por `order`, que lá era `orderBy`, é feita
/// aqui. [familyId] não é usado: no modo local existe uma família só.
class RulesLocalRepository implements RulesRepository {
  RulesLocalRepository(this._store);

  final LocalStore _store;

  @override
  Stream<List<Rule>> watchRules(String familyId) =>
      _store.watch().map((document) => _ordered(document.rules));

  /// Regra nova entra no fim: `order` = relógio em milissegundos, maior que os
  /// índices 0..n-1 gravados por [reorder] e pela semeadura (ADR-0013).
  @override
  Future<Result<void>> addRule(
    String familyId, {
    required String description,
    required int valueCents,
  }) {
    return _store.update(
      (document) => document.copyWith(
        rules: [
          ...document.rules,
          {
            'id': newLocalId(),
            'description': description.trim(),
            'valueCents': valueCents,
            'order': DateTime.now().millisecondsSinceEpoch,
          },
        ],
      ),
    );
  }

  @override
  Future<Result<void>> updateRule(String familyId, Rule rule) {
    return _store.update(
      (document) => document.copyWith(
        rules: [
          for (final map in document.rules)
            if (map['id'] == rule.id)
              {
                ...map,
                'description': rule.description.trim(),
                'valueCents': rule.valueCents,
              }
            else
              map,
        ],
      ),
    );
  }

  /// Apaga a regra e os lançamentos dela em todos os filhos.
  @override
  Future<Result<void>> deleteRule(String familyId, String ruleId) {
    return _store.update(
      (document) => document.copyWith(
        rules: [
          for (final map in document.rules)
            if (map['id'] != ruleId) map,
        ],
        entries: [
          for (final map in document.entries)
            if (map['ruleId'] != ruleId) map,
        ],
      ),
    );
  }

  @override
  Future<Result<void>> reorder(String familyId, List<String> orderedIds) {
    return _store.update(
      (document) => document.copyWith(
        rules: [
          for (final map in document.rules)
            if (orderedIds.indexOf(map['id'] as String) case final index
                when index >= 0)
              {...map, 'order': index}
            else
              map,
        ],
      ),
    );
  }

  @override
  Future<Result<void>> addSuggestions(String familyId, List<RuleSeed> seeds) {
    final base = DateTime.now().millisecondsSinceEpoch;
    return _store.update(
      (document) => document.copyWith(
        rules: [
          ...document.rules,
          for (var i = 0; i < seeds.length; i++)
            {
              'id': newLocalId(),
              'description': seeds[i].description,
              'valueCents': seeds[i].valueCents,
              'order': base + i,
            },
        ],
      ),
    );
  }

  List<Rule> _ordered(List<Map<String, dynamic>> maps) {
    // Dois itens podem empatar no milissegundo de `order`; o id desempata
    // (começa pelo relógio), e `List.sort` não é estável.
    final sorted = [...maps]
      ..sort((a, b) {
        final byOrder = _order(a).compareTo(_order(b));
        return byOrder != 0 ? byOrder : _id(a).compareTo(_id(b));
      });
    return [
      for (final map in sorted)
        RuleDto.fromMap(map['id'] as String, map).toEntity(),
    ];
  }

  int _order(Map<String, dynamic> map) => (map['order'] as num?)?.toInt() ?? 0;

  String _id(Map<String, dynamic> map) => map['id'] as String? ?? '';
}
