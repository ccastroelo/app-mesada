import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/store_product.dart';
import '../../domain/usecases/evaluate_access.dart';
import '../state/entitlement_state.dart';

/// Comprar o app (ADR-0021): a compra única que libera o uso neste aparelho
/// para sempre. Compartilhar com o outro responsável é uma assinatura à parte,
/// em Ajustes › Família.
class PurchasePage extends ConsumerWidget {
  const PurchasePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final access = ref.watch(accessProvider).value;
    final offer = ref.watch(storeOfferProvider(StoreProduct.app));
    final action = ref.watch(purchaseActionsProvider);
    final actions = ref.read(purchaseActionsProvider.notifier);

    final owned =
        access is FullAccess &&
        (access.source == AccessSource.purchased ||
            access.source == AccessSource.legacy);

    Future<void> restore() async {
      final found = await actions.restore();
      if (!context.mounted) return;
      if (found) {
        context.pop();
      } else {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.purchaseRestoreEmpty)));
      }
    }

    Future<void> buy() async {
      final ok = await actions.buy(StoreProduct.app);
      if (ok && context.mounted) context.pop();
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.purchaseTitle)),
      body: ListView(
        padding: const EdgeInsets.all(Space.lg),
        children: [
          if (owned)
            Row(
              children: [
                Icon(Icons.check_circle, color: theme.colorScheme.primary),
                const SizedBox(width: Space.sm),
                Expanded(
                  child: Text(
                    l10n.purchaseOwned,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            )
          else ...[
            Text(l10n.purchasePitch, style: theme.textTheme.titleMedium),
            const SizedBox(height: Space.md),
            Text(l10n.purchaseSharingNote, style: muted),
            const SizedBox(height: Space.xl),
            if (offer.value case final value?)
              FilledButton(
                onPressed: action.loading ? null : buy,
                child: Text(l10n.purchaseBuyAction(value.price)),
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
          ],
        ],
      ),
    );
  }
}
