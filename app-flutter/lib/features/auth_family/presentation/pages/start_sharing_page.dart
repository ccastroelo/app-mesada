import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/app_mode_state.dart';
import '../../../../core/storage/providers.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../entitlement/entitlement.dart';
import '../../../entitlement/entitlement_providers.dart';

/// Ajustes › Família: começar a compartilhar com o outro responsável.
///
/// Compartilhar (sincronizar os dois aparelhos) é uma **assinatura por
/// família** (ADR-0021): quem cria a família assina; o convidado só precisa
/// ter o próprio acesso ao app. Com a assinatura em mãos, o próximo passo é
/// entrar com uma conta — aí entra a nuvem (ADR-0014) e os dados deste
/// aparelho sobem.
class StartSharingPage extends ConsumerWidget {
  const StartSharingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final subscribed = ref.watch(sharingSubscribedProvider);
    final offer = ref.watch(storeOfferProvider(StoreProduct.sharing));
    final action = ref.watch(purchaseActionsProvider);
    final actions = ref.read(purchaseActionsProvider.notifier);

    Future<void> restore() async {
      final found = await actions.restore();
      if (!found && context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.purchaseRestoreEmpty)));
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsFamilySection)),
      body: ListView(
        padding: const EdgeInsets.all(Space.lg),
        children: [
          Text(l10n.sharingPitch, style: theme.textTheme.titleMedium),
          const SizedBox(height: Space.md),
          Text(l10n.sharingOtherNeedsApp, style: muted),
          const SizedBox(height: Space.md),
          Text(l10n.sharingLocalOnly, style: muted),
          if (ref.watch(appModeProvider) == AppMode.local) ...[
            const SizedBox(height: Space.xl),
            if (!subscribed) ...[
              Text(l10n.sharingSubscribeHint, style: muted),
              const SizedBox(height: Space.md),
              if (offer.value case final value?)
                FilledButton(
                  onPressed: action.loading
                      ? null
                      : () => actions.buy(StoreProduct.sharing),
                  child: Text(l10n.sharingSubscribeAction(value.price)),
                )
              else if (offer.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Text(
                  l10n.purchaseStoreUnavailable,
                  style: muted?.copyWith(color: theme.colorScheme.error),
                ),
              const SizedBox(height: Space.md),
              OutlinedButton(
                onPressed: action.loading ? null : restore,
                child: Text(l10n.purchaseRestoreAction),
              ),
            ] else ...[
              Text(l10n.sharingHint, style: muted),
              const SizedBox(height: Space.md),
              FilledButton(
                onPressed: () => setAppMode(ref, AppMode.cloud),
                child: Text(l10n.sharingStart),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
