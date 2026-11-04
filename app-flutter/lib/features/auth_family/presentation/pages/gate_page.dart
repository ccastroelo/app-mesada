import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/providers.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/failure_message.dart';
import '../../../../core/widgets/page_body.dart';
import '../../../../l10n/app_localizations.dart';
import '../state/controllers.dart';
import '../state/gate.dart';

/// Tela de espera enquanto o login e a família carregam; se der erro, oferece
/// tentar de novo ou sair.
class GatePage extends ConsumerWidget {
  const GatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final gate = ref.watch(gateProvider);

    if (gate is! GateError) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // No modo local o erro é do arquivo do aparelho (ADR-0014): não há conta
    // para sair, e tentar de novo precisa reabrir a leitura do arquivo.
    final local = ref.watch(appModeProvider) == AppMode.local;
    final startOver = ref.watch(startOverControllerProvider);

    return Scaffold(
      body: PageBody(
        children: [
          const SizedBox(height: Space.xxl),
          Icon(
            Icons.cloud_off_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: Space.lg),
          Text(
            local ? l10n.localFileErrorTitle : l10n.errorUnexpected,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (local) ...[
            const SizedBox(height: Space.md),
            Text(l10n.localFileErrorBody, textAlign: TextAlign.center),
          ],
          const SizedBox(height: Space.xl),
          FilledButton(
            onPressed: () {
              ref.invalidate(localFamilyProvider);
              ref.invalidate(authUserProvider);
              ref.invalidate(familyIdProvider);
              ref.invalidate(familyProvider);
            },
            child: Text(l10n.tryAgain),
          ),
          const SizedBox(height: Space.md),
          if (local) ...[
            TextButton(
              onPressed: startOver.loading
                  ? null
                  : () => _confirmStartOver(context, ref),
              child: Text(l10n.startOverAction),
            ),
            FailureText(startOver.failure),
          ] else
            TextButton(
              onPressed: () =>
                  ref.read(signOutControllerProvider.notifier).signOut(),
              child: Text(l10n.signOutAction),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmStartOver(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.startOverConfirmTitle),
        content: Text(l10n.startOverConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.startOverAction),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref.read(startOverControllerProvider.notifier).startOver();
    }
  }
}
