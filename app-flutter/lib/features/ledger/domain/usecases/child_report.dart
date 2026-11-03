import '../../../children/children.dart';
import '../../../rules/rules.dart';
import '../entities/entry.dart';
import 'calculate_balance.dart';

/// Uma linha do relatório: a regra, quanto foi lançado e o total dela.
class ChildReportRow {
  const ChildReportRow({
    required this.description,
    required this.valueCents,
    required this.quantity,
  });

  final String description;
  final int valueCents;
  final int quantity;

  int get totalCents => quantity * valueCents;
}

/// O relatório de um filho (ADR-0016), em centavos: quem formata é a tela.
class ChildReport {
  const ChildReport({
    required this.childName,
    required this.childEmail,
    required this.allowanceCents,
    required this.balanceCents,
    required this.rows,
  });

  final String childName;
  final String childEmail;
  final int allowanceCents;
  final int balanceCents;

  /// Na ordem da aba Regras.
  final List<ChildReportRow> rows;
}

/// Monta o relatório do [child]. Entram só as regras **ativas para ele e com
/// quantidade > 0**: o relatório é o retrato do que aconteceu, não da lista de
/// regras. O saldo é o mesmo da tela (`calculateBalanceCents`).
ChildReport buildChildReport({
  required Child child,
  required Iterable<Rule> rules,
  required Iterable<Entry> entries,
}) {
  final byRule = {
    for (final entry in entries)
      if (entry.childId == child.id) entry.ruleId: entry,
  };
  return ChildReport(
    childName: child.name,
    childEmail: child.email,
    allowanceCents: child.allowanceCents,
    balanceCents: calculateBalanceCents(
      child: child,
      rules: rules,
      entries: entries,
    ),
    rows: [
      for (final rule in rules)
        if (byRule[rule.id] case final entry?)
          if (entry.enabled && entry.quantity > 0)
            ChildReportRow(
              description: rule.description,
              valueCents: rule.valueCents,
              quantity: entry.quantity,
            ),
    ],
  );
}
