import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/failure_message.dart';
import '../../../../core/widgets/page_body.dart';
import '../../../../l10n/app_localizations.dart';
import '../state/controllers.dart';

/// Entrar e criar conta com e-mail e senha na mesma tela.
class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _creating = false;
  bool _resetSent = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = ref.read(signInControllerProvider.notifier);
    setState(() => _resetSent = false);
    if (_creating) {
      await controller.signUp(_email.text, _password.text);
    } else {
      await controller.signIn(_email.text, _password.text);
    }
  }

  Future<void> _forgotPassword() async {
    if (!_isEmail(_email.text)) {
      _formKey.currentState!.validate();
      return;
    }
    final ok = await ref
        .read(signInControllerProvider.notifier)
        .sendPasswordReset(_email.text);
    if (ok && mounted) setState(() => _resetSent = true);
  }

  bool _isEmail(String value) =>
      RegExp(r'^\S+@\S+\.\S+$').hasMatch(value.trim());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final action = ref.watch(signInControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_creating ? l10n.signUpTitle : l10n.signInTitle),
      ),
      body: PageBody(
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  decoration: InputDecoration(labelText: l10n.emailLabel),
                  validator: (value) =>
                      _isEmail(value ?? '') ? null : l10n.emailInvalid,
                ),
                const SizedBox(height: Space.md),
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: [
                    _creating
                        ? AutofillHints.newPassword
                        : AutofillHints.password,
                  ],
                  decoration: InputDecoration(labelText: l10n.passwordLabel),
                  validator: (value) =>
                      (value ?? '').length >= 6 ? null : l10n.passwordTooShort,
                  onFieldSubmitted: (_) => _submit(),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.lg),
          FilledButton(
            onPressed: action.loading ? null : _submit,
            child: Text(_creating ? l10n.signUpAction : l10n.signInAction),
          ),
          if (action.loading)
            const Padding(
              padding: EdgeInsets.only(top: Space.lg),
              child: Center(child: CircularProgressIndicator()),
            ),
          FailureText(action.failure),
          if (_resetSent)
            Padding(
              padding: const EdgeInsets.only(top: Space.sm),
              child: Semantics(
                liveRegion: true,
                child: Text(l10n.passwordResetSent),
              ),
            ),
          const SizedBox(height: Space.md),
          if (!_creating)
            TextButton(
              onPressed: action.loading ? null : _forgotPassword,
              child: Text(l10n.forgotPassword),
            ),
          TextButton(
            onPressed: action.loading
                ? null
                : () {
                    ref.read(signInControllerProvider.notifier).clearFailure();
                    setState(() {
                      _creating = !_creating;
                      _resetSent = false;
                    });
                  },
            child: Text(_creating ? l10n.switchToSignIn : l10n.switchToSignUp),
          ),
        ],
      ),
    );
  }
}
