import '../../../children/children.dart';
import '../../../rules/rules.dart';
import '../entities/entry.dart';

/// Saldo do filho = mesada inicial + Σ(quantidade × valor da regra)
/// (`imMesadeiro.m:24-28`, `imGrupoLancamentos.m:238-248`).
///
/// Só entram lançamentos do próprio [child] com a regra ativada e existente em
/// [rules]. Lançamento de regra já excluída é ignorado.
int calculateBalanceCents({
  required Child child,
  required Iterable<Rule> rules,
  required Iterable<Entry> entries,
}) {
  final valueByRule = {for (final rule in rules) rule.id: rule.valueCents};
  var balance = child.allowanceCents;
  for (final entry in entries) {
    if (entry.childId != child.id || !entry.enabled) continue;
    final value = valueByRule[entry.ruleId];
    if (value == null) continue;
    balance += entry.quantity * value;
  }
  return balance;
}
