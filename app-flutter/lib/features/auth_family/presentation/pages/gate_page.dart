import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/tokens.dart';
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
            l10n.errorUnexpected,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: Space.xl),
          FilledButton(
            onPressed: () {
              ref.invalidate(authUserProvider);
              ref.invalidate(familyIdProvider);
              ref.invalidate(familyProvider);
            },
            child: Text(l10n.tryAgain),
          ),
          const SizedBox(height: Space.md),
          TextButton(
            onPressed: () =>
                ref.read(signOutControllerProvider.notifier).signOut(),
            child: Text(l10n.signOutAction),
          ),
        ],
      ),
    );
  }
}
