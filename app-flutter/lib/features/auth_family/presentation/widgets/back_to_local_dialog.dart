import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/failure_message.dart';
import '../../../../l10n/app_localizations.dart';
import '../state/controllers.dart';

/// Confirma e faz a volta para o uso só neste aparelho (ADR-0014): baixa um
/// retrato da família para o arquivo local e troca o modo.
Future<void> showBackToLocalDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const _BackToLocalDialog(),
  );
}

class _BackToLocalDialog extends ConsumerWidget {
  const _BackToLocalDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final action = ref.watch(backToLocalControllerProvider);

    return AlertDialog(
      title: Text(l10n.backToLocalDialogTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.backToLocalDialogBody),
            FailureText(action.failure),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: action.loading ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancelAction),
        ),
        FilledButton(
          onPressed: action.loading
              ? null
              : () async {
                  final done = await ref
                      .read(backToLocalControllerProvider.notifier)
                      .leave();
                  if (done && context.mounted) Navigator.of(context).pop();
                },
          child: action.loading
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.backToLocalAction),
        ),
      ],
    );
  }
}
