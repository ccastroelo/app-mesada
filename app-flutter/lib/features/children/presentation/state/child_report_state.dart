import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/money.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../ledger/ledger.dart';
import '../../../ledger/ledger_providers.dart';
import '../../../rules/rules_providers.dart';
import 'child_ledger_state.dart';

/// O relatório do filho em centavos (ADR-0016); null enquanto os dados não
/// chegaram ou se o filho não existe mais.
final childReportProvider = Provider.family<ChildReport?, String>((
  ref,
  childId,
) {
  final ledger = ref.watch(childLedgerProvider(childId)).value;
  final rules = ref.watch(rulesProvider).value;
  final entries = ref.watch(entriesProvider).value;
  if (ledger == null || rules == null || entries == null) return null;
  return buildChildReport(child: ledger.child, rules: rules, entries: entries);
});

/// Monta o documento (tudo em texto: moeda, data e idioma vivem aqui) e manda
/// compartilhar. Usado pela tela do filho e pelo menu do cartão.
Future<bool> shareChildReport(
  BuildContext context,
  WidgetRef ref,
  String childId,
) {
  final report = ref.read(childReportProvider(childId));
  if (report == null) return Future.value(false);
  return ref
      .read(ledgerActionsProvider.notifier)
      .shareReport(reportDocument(context, report));
}

@visibleForTesting
ReportDocument reportDocument(BuildContext context, ChildReport report) {
  final l10n = AppLocalizations.of(context);
  final locale = Localizations.localeOf(context).toString();
  String money(int cents, {bool signed = false}) =>
      formatCents(cents, locale: locale, signed: signed);

  final allowance = money(report.allowanceCents);
  final balance = money(report.balanceCents);
  final summary = l10n.reportSummary(report.childName, allowance, balance);

  return ReportDocument(
    fileName: _fileName(report.childName),
    title: l10n.reportTitle(report.childName),
    subtitle: l10n.reportGeneratedAt(
      DateFormat.yMMMMd(locale).format(DateTime.now()),
    ),
    // O e-mail do filho vai no texto porque a folha do sistema não aceita
    // destinatário (ADR-0016): fica a um "colar" de distância.
    summary: report.childEmail.isEmpty
        ? summary
        : '$summary\n${report.childEmail}',
    columns: [
      l10n.reportRuleColumn,
      l10n.reportValueColumn,
      l10n.reportQuantityColumn,
      l10n.reportTotalColumn,
    ],
    rows: [
      for (final row in report.rows)
        [
          row.description,
          money(row.valueCents, signed: true),
          '${row.quantity}',
          money(row.totalCents, signed: true),
        ],
    ],
    totals: [
      (label: l10n.childAllowanceLabel, value: allowance),
      (label: l10n.balanceLabel, value: balance),
    ],
    emptyMessage: l10n.reportEmpty,
  );
}

/// "mesada-lucas-castro.pdf". Nome de arquivo some de muitos sistemas se
/// levar acento ou espaço, então sobra o que é seguro.
String _fileName(String childName) {
  final slug = childName
      .toLowerCase()
      .replaceAll(RegExp('[^a-z0-9]+'), '-')
      .replaceAll(RegExp('^-+|-+\$'), '');
  return slug.isEmpty ? 'mesada.pdf' : 'mesada-$slug.pdf';
}
