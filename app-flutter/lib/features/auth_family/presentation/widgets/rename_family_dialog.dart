import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/failure_message.dart';
import '../../../../l10n/app_localizations.dart';
import '../state/controllers.dart';

/// Edita o nome da família no modo local (Ajustes). [current] vem vazio
/// enquanto a pessoa ainda não deu nome: o campo começa em branco e a tela
/// continua mostrando o padrão do idioma.
Future<void> showRenameFamilyDialog(BuildContext context, String current) {
  return showDialog<void>(
    context: context,
    builder: (_) => _RenameFamilyDialog(current: current),
  );
}

class _RenameFamilyDialog extends ConsumerStatefulWidget {
  const _RenameFamilyDialog({required this.current});

  final String current;

  @override
  ConsumerState<_RenameFamilyDialog> createState() =>
      _RenameFamilyDialogState();
}

class _RenameFamilyDialogState extends ConsumerState<_RenameFamilyDialog> {
  late final _controller = TextEditingController(text: widget.current);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final done = await ref
        .read(renameLocalFamilyControllerProvider.notifier)
        .rename(_controller.text);
    if (done && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final action = ref.watch(renameLocalFamilyControllerProvider);

    return AlertDialog(
      title: Text(l10n.renameFamilyTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: 60,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: l10n.familyNameLabel,
              hintText: l10n.familyDefaultName,
            ),
            onSubmitted: (_) => _save(),
          ),
          FailureText(action.failure),
        ],
      ),
      actions: [
        TextButton(
          onPressed: action.loading ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancelAction),
        ),
        FilledButton(
          onPressed: action.loading ? null : _save,
          child: Text(l10n.saveAction),
        ),
      ],
    );
  }
}
