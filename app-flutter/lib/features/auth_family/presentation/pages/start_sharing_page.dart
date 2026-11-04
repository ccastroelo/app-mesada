import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/app_mode_state.dart';
import '../../../../core/storage/providers.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../l10n/app_localizations.dart';

/// Ajustes › Família: começar a compartilhar com o outro responsável.
///
/// O compartilhamento já vem incluso no app (ADR-0021): não há compra aqui. O
/// único passo é a pessoa escolher compartilhar — aí entram a conta e a nuvem
/// (ADR-0014), e os dados deste aparelho sobem.
class StartSharingPage extends ConsumerWidget {
  const StartSharingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

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
            Text(l10n.sharingHint, style: muted),
            const SizedBox(height: Space.md),
            FilledButton(
              onPressed: () => setAppMode(ref, AppMode.cloud),
              child: Text(l10n.sharingStart),
            ),
          ],
        ],
      ),
    );
  }
}
