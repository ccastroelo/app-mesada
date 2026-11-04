import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/failure_message.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../entitlement/entitlement_providers.dart';
import '../../../ledger/ledger_providers.dart';
import '../../../rules/rules_providers.dart';
import '../state/child_ledger_state.dart';
import '../state/children_state.dart';

/// Quais regras valem para este filho. Desativar **preserva** a quantidade,
/// só tira do saldo (ADR-0008); é o lugar do "remover linha" do legado.
class ChildRulesPage extends ConsumerWidget {
  const ChildRulesPage({super.key, required this.childId});

  final String childId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ledger = ref.watch(childLedgerProvider(childId));
    final action = ref.watch(ledgerActionsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.childRulesMenu)),
      body: ledger.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => ErrorState(
          onRetry: () {
            ref.invalidate(childrenProvider);
            ref.invalidate(rulesProvider);
            ref.invalidate(entriesProvider);
          },
        ),
        data: (data) {
          if (data.rows.isEmpty) {
            return EmptyState(
              icon: Icons.rule_outlined,
              title: l10n.childLedgerEmptyTitle,
              body: l10n.childLedgerEmptyBody,
            );
          }
          final rewards = [
            for (final row in data.rows)
              if (row.rule.isReward) row,
          ];
          final discounts = [
            for (final row in data.rows)
              if (row.rule.isDiscount) row,
          ];
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.only(bottom: Space.xl),
              children: [
                const AccessBanner(showTrial: false),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Space.lg,
                    Space.md,
                    Space.lg,
                    0,
                  ),
                  child: Text(l10n.childRulesSubtitle),
                ),
                if (action.failure != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Space.lg),
                    child: FailureText(action.failure),
                  ),
                if (rewards.isNotEmpty) ...[
                  SectionHeader(l10n.rulesRewardsSection),
                  for (final row in rewards)
                    _RuleSwitch(childId: childId, row: row),
                ],
                if (discounts.isNotEmpty) ...[
                  SectionHeader(l10n.rulesDiscountsSection),
                  for (final row in discounts)
                    _RuleSwitch(childId: childId, row: row),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RuleSwitch extends ConsumerWidget {
  const _RuleSwitch({required this.childId, required this.row});

  final String childId;
  final LedgerRow row;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.mesadaColors;
    final canWrite = ref.watch(canWriteProvider);
    final rule = row.rule;
    final value = formatCents(
      rule.valueCents,
      locale: Localizations.localeOf(context).toString(),
      signed: true,
    );
    return SwitchListTile(
      value: row.enabled,
      onChanged: !canWrite
          ? null
          : (enabled) => ref
                .read(ledgerActionsProvider.notifier)
                .setEnabled(
                  childId: childId,
                  ruleId: rule.id,
                  enabled: enabled,
                ),
      title: Text(rule.description),
      subtitle: Text(value),
      secondary: ExcludeSemantics(
        child: Icon(
          rule.isReward ? Icons.trending_up : Icons.trending_down,
          color: rule.isReward ? colors.positive : colors.negative,
        ),
      ),
    );
  }
}
