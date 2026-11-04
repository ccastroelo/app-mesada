import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/failure_message.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/usecases/pin_lock_rules.dart';
import '../state/app_lock_state.dart';
import '../widgets/pin_pad.dart';

/// O que a pessoa pediu: ativar, alterar ou desativar o PIN.
enum _Goal { enable, change, disable, recovery }

/// Em que passo a digitação está.
enum _Step { idle, current, create, confirm, email }

/// Ajustes › Segurança (design.md §4.8 e §4.11). O PIN é deste aparelho.
class SecurityPage extends ConsumerStatefulWidget {
  const SecurityPage({super.key});

  @override
  ConsumerState<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends ConsumerState<SecurityPage> {
  _Goal? _goal;
  _Step _step = _Step.idle;
  String? _firstTyped;
  String? _error;

  final _emailController = TextEditingController();
  bool _saving = false;
  Failure? _emailFailure;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _start(_Goal goal) {
    setState(() {
      _goal = goal;
      _error = null;
      _firstTyped = null;
      // Mexer num PIN que já existe pede o atual primeiro.
      _step = goal == _Goal.enable ? _Step.create : _Step.current;
    });
  }

  void _cancel() => setState(() {
    _goal = null;
    _step = _Step.idle;
    _firstTyped = null;
    _error = null;
    _emailFailure = null;
    _emailController.clear();
  });

  /// Registra o e-mail de recuperação no servidor (ADR-0023). O erro aparece
  /// abaixo do campo, nunca só em snackbar.
  Future<void> _saveEmail() async {
    final l10n = AppLocalizations.of(context);
    final email = _emailController.text.trim();
    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!valid) {
      setState(() => _emailFailure = const InvalidEmail());
      return;
    }
    final locale = Localizations.localeOf(context);
    setState(() {
      _saving = true;
      _emailFailure = null;
    });
    final result = await ref
        .read(appLockProvider.notifier)
        .registerRecovery(
          email,
          recoveryLocale(locale.languageCode, locale.countryCode),
        );
    if (!mounted) return;
    switch (result) {
      case Ok():
        setState(() => _saving = false);
        _finish(l10n.recoverySaved);
      case Err(:final failure):
        setState(() {
          _saving = false;
          _emailFailure = failure;
        });
    }
  }

  /// "Agora não" ao ativar o PIN; "Cancelar" ao trocar o e-mail depois.
  void _skipEmail() {
    final l10n = AppLocalizations.of(context);
    if (_goal == _Goal.enable) {
      _finish(l10n.pinStatusOn);
    } else {
      _cancel();
    }
  }

  Future<void> _typed(String pin) async {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(appLockProvider.notifier);

    switch (_step) {
      case _Step.current:
        if (!controller.matches(pin)) {
          setState(() => _error = l10n.pinWrong);
          return;
        }
        if (_goal == _Goal.disable) {
          await controller.disablePin(pin);
          if (mounted) _finish(l10n.pinStatusOff);
          return;
        }
        if (_goal == _Goal.recovery) {
          // Trocar o e-mail pede o PIN atual: senão o filho mandaria o PIN
          // novo para o e-mail dele.
          setState(() {
            _error = null;
            _step = _Step.email;
          });
          return;
        }
        setState(() {
          _error = null;
          _step = _Step.create;
        });

      case _Step.create:
        setState(() {
          _firstTyped = pin;
          _error = null;
          _step = _Step.confirm;
        });

      case _Step.confirm:
        if (pin != _firstTyped) {
          setState(() {
            _error = l10n.pinMismatch;
            _firstTyped = null;
            _step = _Step.create;
          });
          return;
        }
        await controller.enablePin(pin);
        if (!mounted) return;
        // Com servidor configurado, o PIN recém-criado vem com a chance de
        // registrar o e-mail de recuperação (ADR-0023).
        if (controller.recoveryAvailable) {
          setState(() {
            _error = null;
            _step = _Step.email;
          });
          return;
        }
        _finish(l10n.pinStatusOn);

      case _Step.email || _Step.idle:
        return;
    }
  }

  /// Ligar a biometria exige provar que ela funciona neste aparelho; desligar
  /// é direto (ADR-0018).
  Future<void> _toggleBiometrics(bool value) async {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(appLockProvider.notifier);
    if (!value) {
      await controller.disableBiometrics();
      if (mounted) setState(() {});
      return;
    }
    final ok = await controller.enableBiometrics(l10n.biometricsReason);
    if (!mounted) return;
    setState(() {});
    if (!ok) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.biometricsUnavailable)));
    }
  }

  void _finish(String message) {
    _cancel();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Passo do e-mail de recuperação: explica o que acontece e o risco.
  Widget _emailForm(AppLocalizations l10n, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.recoveryTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: Space.md),
        Text(
          l10n.recoveryExplain,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Space.lg),
        TextField(
          controller: _emailController,
          autofocus: true,
          enabled: !_saving,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(labelText: l10n.recoveryEmailLabel),
          onSubmitted: (_) => _saveEmail(),
        ),
        FailureText(_emailFailure),
        const SizedBox(height: Space.lg),
        FilledButton(
          onPressed: _saving ? null : _saveEmail,
          child: _saving
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.saveAction),
        ),
        TextButton(
          onPressed: _saving ? null : _skipEmail,
          child: Text(
            _goal == _Goal.enable ? l10n.recoverySkipAction : l10n.cancelAction,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final lock = ref.watch(appLockProvider);
    final enabled = lock is! LockLoading && lock is! LockOff;
    final recoveryEmail = ref.read(appLockProvider.notifier).recoveryEmail;
    final recoveryAvailable = ref
        .read(appLockProvider.notifier)
        .recoveryAvailable;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsSecuritySection)),
      body: _step == _Step.idle
          ? ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(Space.lg),
                  child: Text(
                    l10n.securityExplanation,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                SectionHeader(l10n.pinSectionTitle),
                ListTile(
                  leading: Icon(enabled ? Icons.lock : Icons.lock_open),
                  title: Text(enabled ? l10n.pinStatusOn : l10n.pinStatusOff),
                ),
                if (!enabled)
                  ListTile(
                    leading: const Icon(Icons.pin_outlined),
                    title: Text(l10n.pinEnableAction),
                    onTap: () => _start(_Goal.enable),
                  ),
                if (enabled) ...[
                  SwitchListTile(
                    value: ref.read(appLockProvider.notifier).biometricsEnabled,
                    onChanged: _toggleBiometrics,
                    secondary: const Icon(Icons.fingerprint),
                    title: Text(l10n.biometricsTitle),
                    subtitle: Text(l10n.biometricsSubtitle),
                  ),
                  ListTile(
                    leading: const Icon(Icons.pin_outlined),
                    title: Text(l10n.pinChangeAction),
                    onTap: () => _start(_Goal.change),
                  ),
                  if (recoveryAvailable)
                    ListTile(
                      leading: const Icon(Icons.mark_email_read_outlined),
                      title: Text(l10n.recoveryTitle),
                      subtitle: Text(
                        recoveryEmail == null
                            ? l10n.recoveryNotSet
                            : maskEmail(recoveryEmail),
                      ),
                      onTap: () => _start(_Goal.recovery),
                    ),
                  ListTile(
                    leading: const Icon(Icons.lock_open_outlined),
                    title: Text(l10n.pinDisableAction),
                    onTap: () => _start(_Goal.disable),
                  ),
                ],
              ],
            )
          : SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(Space.xl),
                  child: _step == _Step.email
                      ? _emailForm(l10n, theme)
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PinPad(
                              message: switch (_step) {
                                _Step.current => l10n.pinEnterCurrent,
                                _Step.create => l10n.pinEnterNew,
                                _Step.confirm => l10n.pinConfirmNew,
                                _Step.email || _Step.idle => '',
                              },
                              errorText: _error,
                              onCompleted: _typed,
                            ),
                            const SizedBox(height: Space.lg),
                            TextButton(
                              onPressed: _cancel,
                              child: Text(l10n.cancelAction),
                            ),
                          ],
                        ),
                ),
              ),
            ),
    );
  }
}
