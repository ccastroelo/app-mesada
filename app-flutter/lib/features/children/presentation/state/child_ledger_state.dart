import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ledger/ledger.dart';
import '../../../ledger/ledger_providers.dart';
import '../../../rules/rules.dart';
import '../../../rules/rules_providers.dart';
import '../../domain/entities/child.dart';
import 'children_state.dart';

/// O filho pedido não está mais na lista: o outro responsável o excluiu com
/// a tela aberta. A tela troca o erro genérico por voltar à lista.
class ChildNotFound implements Exception {
  const ChildNotFound(this.childId);

  final String childId;

  @override
  String toString() => 'ChildNotFound($childId)';
}

/// Uma linha da tela do filho: a regra, quanto já foi lançado e se a regra
/// está ativa para esse filho (ADR-0008).
class LedgerRow {
  const LedgerRow({
    required this.rule,
    required this.quantity,
    required this.enabled,
  });

  final Rule rule;
  final int quantity;
  final bool enabled;

  int get totalCents => quantity * rule.valueCents;
}

/// O filho, suas linhas e o saldo — o que a tela de lançamentos desenha.
class ChildLedger {
  const ChildLedger({
    required this.child,
    required this.rows,
    required this.balanceCents,
  });

  final Child child;

  /// Todas as regras, na ordem da aba Regras, **inclusive as desativadas**
  /// (a tela de lançamentos esconde; a de regras do filho mostra com switch).
  final List<LedgerRow> rows;

  final int balanceCents;

  List<LedgerRow> get rewards => [
    for (final row in rows)
      if (row.enabled && row.rule.isReward) row,
  ];

  List<LedgerRow> get discounts => [
    for (final row in rows)
      if (row.enabled && row.rule.isDiscount) row,
  ];

  bool get hasActiveRows => rows.any((row) => row.enabled);
}

/// Junta filho, regras e lançamentos. Carregando até os três chegarem; erro se
/// qualquer um falhar, ou se o filho não existir mais (o outro responsável
/// pode ter excluído com a tela aberta).
final childLedgerProvider = Provider.family<AsyncValue<ChildLedger>, String>((
  ref,
  childId,
) {
  final children = ref.watch(childrenProvider);
  final rules = ref.watch(rulesProvider);
  final entries = ref.watch(entriesProvider);

  for (final source in [children, rules, entries]) {
    if (source.hasError) {
      return AsyncValue.error(
        source.error!,
        source.stackTrace ?? StackTrace.empty,
      );
    }
  }
  if (!children.hasValue || !rules.hasValue || !entries.hasValue) {
    return const AsyncValue.loading();
  }

  Child? found;
  for (final candidate in children.value!) {
    if (candidate.id == childId) found = candidate;
  }
  final child = found;
  if (child == null) {
    return AsyncValue.error(ChildNotFound(childId), StackTrace.empty);
  }

  final byRule = {
    for (final entry in entries.value!)
      if (entry.childId == childId) entry.ruleId: entry,
  };
  return AsyncValue.data(
    ChildLedger(
      child: child,
      rows: [
        for (final rule in rules.value!)
          LedgerRow(
            rule: rule,
            quantity: byRule[rule.id]?.quantity ?? 0,
            enabled: byRule[rule.id]?.enabled ?? true,
          ),
      ],
      balanceCents: calculateBalanceCents(
        child: child,
        rules: rules.value!,
        entries: entries.value!,
      ),
    ),
  );
});
