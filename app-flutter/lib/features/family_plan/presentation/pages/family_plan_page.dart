import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/storage/app_mode_state.dart';
import '../../../../core/storage/providers.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/failure_message.dart';
import '../../../../l10n/app_localizations.dart';
import '../state/family_plan_state.dart';

/// Ajustes › Família: o recurso pago (ADR-0015/0020). Pagamento único por
/// família; quem compra libera, o outro responsável entra de graça.
class FamilyPlanPage extends ConsumerWidget {
  const FamilyPlanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final plan = ref.watch(familyPlanProvider);
    final offer = ref.watch(planOfferProvider);
    final action = ref.watch(familyPlanActionsProvider);
    final actions = ref.read(familyPlanActionsProvider.notifier);
    final locale = Localizations.localeOf(context).toString();

    Future<void> restore() async {
      final ok = await actions.restore();
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.planRestoreEmpty)));
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsFamilySection)),
      body: switch (plan.value) {
        null => const Center(child: CircularProgressIndicator()),
        final value when value.shares => ListView(
          padding: const EdgeInsets.all(Space.lg),
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: theme.colorScheme.primary),
                const SizedBox(width: Space.sm),
                Expanded(
                  child: Text(
                    l10n.planActiveTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Space.sm),
            // A marca de qual modelo valia na compra fica à vista: é o que
            // garante não cobrar de novo se a cobrança mudar (ADR-0020).
            Text(
              value.since == null
                  ? l10n.planOneTime
                  : l10n.planActiveSince(
                      DateFormat.yMMMMd(locale).format(value.since!),
                    ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Space.xl),
            // Comprado mas ainda sem conta: aqui começa a virada para a
            // nuvem (ADR-0014). Entrar leva ao fluxo de conta e família.
            if (ref.watch(appModeProvider) == AppMode.local) ...[
              Text(
                l10n.planSharingHint,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Space.md),
              FilledButton(
                onPressed: () => setAppMode(ref, AppMode.cloud),
                child: Text(l10n.planStartSharing),
              ),
              const SizedBox(height: Space.md),
            ],
            OutlinedButton(
              onPressed: action.loading ? null : restore,
              child: Text(l10n.planRestoreAction),
            ),
          ],
        ),
        _ => ListView(
          padding: const EdgeInsets.all(Space.lg),
          children: [
            Text(l10n.planPitch, style: theme.textTheme.titleMedium),
            const SizedBox(height: Space.md),
            Text(
              l10n.planLocalOnly,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Space.md),
            Text(l10n.planOneTime, style: theme.textTheme.bodyMedium),
            const SizedBox(height: Space.xl),
            if (offer.value case final value?)
              FilledButton(
                onPressed: action.loading ? null : actions.buy,
                child: Text(l10n.planBuyAction(value.price)),
              )
            else if (offer.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Text(
                l10n.planStoreUnavailable,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            const SizedBox(height: Space.md),
            OutlinedButton(
              onPressed: action.loading ? null : restore,
              child: Text(l10n.planRestoreAction),
            ),
            if (action.failure != null)
              Padding(
                padding: const EdgeInsets.only(top: Space.md),
                child: FailureText(action.failure),
              ),
          ],
        ),
      },
    );
  }
}
