import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/failure_message.dart';
import '../../../../core/widgets/page_body.dart';
import '../../../../l10n/app_localizations.dart';
import '../state/controllers.dart';

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final action = ref.watch(signInControllerProvider);

    return Scaffold(
      body: PageBody(
        children: [
          const SizedBox(height: Space.xxl),
          ExcludeSemantics(
            child: Icon(
              Icons.savings_outlined,
              size: 72,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: Space.lg),
          Text(
            l10n.appTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineLarge,
          ),
          const SizedBox(height: Space.md),
          Text(
            l10n.welcomeTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: Space.xxl),
          FilledButton.icon(
            onPressed: action.loading
                ? null
                : () => ref
                      .read(signInControllerProvider.notifier)
                      .signInWithGoogle(),
            icon: const Icon(Icons.login),
            label: Text(l10n.continueWithGoogle),
          ),
          const SizedBox(height: Space.md),
          OutlinedButton.icon(
            onPressed: action.loading ? null : () => context.push('/entrar'),
            icon: const Icon(Icons.mail_outline),
            label: Text(l10n.continueWithEmail),
          ),
          if (action.loading)
            const Padding(
              padding: EdgeInsets.only(top: Space.lg),
              child: Center(child: CircularProgressIndicator()),
            ),
          FailureText(action.failure),
        ],
      ),
    );
  }
}
