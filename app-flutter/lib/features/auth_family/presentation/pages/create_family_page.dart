import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/failure_message.dart';
import '../../../../core/widgets/page_body.dart';
import '../../../../l10n/app_localizations.dart';
import '../state/controllers.dart';

class CreateFamilyPage extends ConsumerStatefulWidget {
  const CreateFamilyPage({super.key});

  @override
  ConsumerState<CreateFamilyPage> createState() => _CreateFamilyPageState();
}

class _CreateFamilyPageState extends ConsumerState<CreateFamilyPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final languageCode = Localizations.localeOf(context).languageCode;
    await ref
        .read(createFamilyControllerProvider.notifier)
        .create(_name.text, languageCode);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final action = ref.watch(createFamilyControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createFamilyTitle)),
      body: PageBody(
        children: [
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              maxLength: 60,
              decoration: InputDecoration(
                labelText: l10n.familyNameLabel,
                hintText: l10n.familyNameHint,
              ),
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? l10n.familyNameRequired : null,
              onFieldSubmitted: (_) => _submit(),
            ),
          ),
          const SizedBox(height: Space.lg),
          FilledButton(
            onPressed: action.loading ? null : _submit,
            child: Text(l10n.createFamilyAction),
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
