import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/state/action_controller.dart';
import '../../../auth_family/auth_family.dart';
import '../../data/providers.dart';
import '../../domain/default_rules.dart';
import '../../domain/entities/rule.dart';

/// Id da família atual; null enquanto a entrada não terminou.
final _familyIdProvider = Provider<String?>((ref) {
  final gate = ref.watch(gateProvider);
  return gate is GateReady ? gate.family.id : null;
});

/// Regras da família, na ordem de exibição.
final rulesProvider = StreamProvider<List<Rule>>((ref) {
  final familyId = ref.watch(_familyIdProvider);
  if (familyId == null) return Stream.value(const <Rule>[]);
  return ref.watch(rulesRepositoryProvider).watchRules(familyId);
});

class RulesActions extends ActionController {
  Future<bool> _withFamily(
    Future<Result<void>> Function(String familyId) action,
  ) => run(() async {
    final familyId = ref.read(_familyIdProvider);
    if (familyId == null) return const Err(Unexpected());
    return action(familyId);
  });

  Future<bool> add({required String description, required int valueCents}) =>
      _withFamily(
        (familyId) => ref
            .read(rulesRepositoryProvider)
            .addRule(
              familyId,
              description: description,
              valueCents: valueCents,
            ),
      );

  Future<bool> update(Rule rule) => _withFamily(
    (familyId) => ref.read(rulesRepositoryProvider).updateRule(familyId, rule),
  );

  Future<bool> delete(String ruleId) => _withFamily(
    (familyId) =>
        ref.read(rulesRepositoryProvider).deleteRule(familyId, ruleId),
  );

  Future<bool> reorder(List<String> orderedIds) => _withFamily(
    (familyId) =>
        ref.read(rulesRepositoryProvider).reorder(familyId, orderedIds),
  );

  /// Repõe as regras-padrão do idioma ([languageCode]) no fim da lista.
  Future<bool> addSuggestions(String languageCode) => _withFamily(
    (familyId) => ref
        .read(rulesRepositoryProvider)
        .addSuggestions(familyId, defaultRulesFor(languageCode)),
  );
}

/// Ações de escrita de regras. Compartilhado por lista e edição; o estado é
/// descartado quando nenhuma tela o observa.
final rulesActionsProvider =
    NotifierProvider.autoDispose<RulesActions, ActionState>(RulesActions.new);
