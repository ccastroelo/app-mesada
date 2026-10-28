import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/error/result.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/failure_message.dart';
import '../../../../l10n/app_localizations.dart';
import '../state/controllers.dart';

/// Gera um código de convite novo e mostra, com copiar e compartilhar.
Future<void> showInviteDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const _InviteDialog(),
  );
}

class _InviteDialog extends ConsumerWidget {
  const _InviteDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final invite = ref.watch(inviteCodeProvider);

    final code = invite.value is Ok<String>
        ? (invite.value! as Ok<String>).value
        : null;

    return AlertDialog(
      title: Text(l10n.inviteDialogTitle),
      content: SingleChildScrollView(
        child: invite.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Text(l10n.errorUnexpected),
          data: (result) => switch (result) {
            Ok(:final value) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SelectableText(
                    value,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      letterSpacing: 4,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                const SizedBox(height: Space.md),
                Text(l10n.inviteDialogBody),
              ],
            ),
            Err(:final failure) => Text(
              failureMessage(l10n, failure) ?? l10n.errorUnexpected,
            ),
          },
        ),
      ),
      actions: [
        if (code != null) ...[
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: code));
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.inviteCopied)));
              }
            },
            child: Text(l10n.inviteCopy),
          ),
          TextButton(
            onPressed: () => SharePlus.instance.share(
              ShareParams(text: l10n.inviteShareText(code)),
            ),
            child: Text(l10n.inviteShare),
          ),
        ],
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.close),
        ),
      ],
    );
  }
}
