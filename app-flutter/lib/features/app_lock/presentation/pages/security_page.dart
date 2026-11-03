import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../state/app_lock_state.dart';
import '../widgets/pin_pad.dart';

/// O que a pessoa pediu: ativar, alterar ou desativar o PIN.
enum _Goal { enable, change, disable }

/// Em que passo a digitação está.
enum _Step { idle, current, create, confirm }

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
  });

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
        if (mounted) _finish(l10n.pinStatusOn);

      case _Step.idle:
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final lock = ref.watch(appLockProvider);
    final enabled = lock is! LockLoading && lock is! LockOff;

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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PinPad(
                        message: switch (_step) {
                          _Step.current => l10n.pinEnterCurrent,
                          _Step.create => l10n.pinEnterNew,
                          _Step.confirm => l10n.pinConfirmNew,
                          _Step.idle => '',
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
