import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/failure_message.dart';
import '../../../../core/widgets/page_body.dart';
import '../../../../l10n/app_localizations.dart';
import '../state/controllers.dart';

class JoinFamilyPage extends ConsumerStatefulWidget {
  const JoinFamilyPage({super.key});

  @override
  ConsumerState<JoinFamilyPage> createState() => _JoinFamilyPageState();
}

class _JoinFamilyPageState extends ConsumerState<JoinFamilyPage> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() {
    return ref.read(joinFamilyControllerProvider.notifier).join(_code.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final action = ref.watch(joinFamilyControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.joinFamilyTitle)),
      body: PageBody(
        children: [
          TextField(
            controller: _code,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\- ]')),
              LengthLimitingTextInputFormatter(10),
            ],
            style: Theme.of(context).textTheme.headlineSmall,
            decoration: InputDecoration(labelText: l10n.inviteCodeLabel),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: Space.lg),
          FilledButton(
            onPressed: action.loading ? null : _submit,
            child: Text(l10n.joinFamilyAction),
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
