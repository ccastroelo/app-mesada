import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/failure_message.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/usecases/pin_lock_rules.dart';
import '../state/app_lock_state.dart';
import '../widgets/pin_pad.dart';

/// Tela do PIN, cobrindo tudo (design.md §4.11). Não tem como voltar: ou
/// acerta o PIN, ou espera.
class LockPage extends ConsumerStatefulWidget {
  const LockPage({super.key});

  @override
  ConsumerState<LockPage> createState() => _LockPageState();
}

class _LockPageState extends ConsumerState<LockPage> {
  /// Último erro, para mostrar "PIN incorreto" só depois de uma tentativa.
  bool _wrong = false;

  /// Redesenha a contagem regressiva a cada segundo.
  Timer? _ticker;

  /// "Esqueci o PIN" (ADR-0023): enviando, e o que voltou.
  bool _sending = false;
  Failure? _recoveryFailure;
  String? _sentTo;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    // Com biometria ligada, pedir logo ao abrir é o caminho esperado: o PIN
    // fica como reserva, atrás do teclado que já está na tela (ADR-0018).
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometrics());
  }

  Future<void> _tryBiometrics() async {
    final controller = ref.read(appLockProvider.notifier);
    if (!controller.biometricsEnabled) return;
    final reason = AppLocalizations.of(context).biometricsReason;
    await controller.unlockWithBiometrics(reason);
    // Se não reconheceu, a tela segue como está: o teclado do PIN vale.
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _submit(String pin) {
    final controller = ref.read(appLockProvider.notifier);
    final ok = controller.unlock(pin);
    if (!ok) {
      // Sem await: o retorno vem da plataforma e o aviso não espera por ele.
      unawaited(HapticFeedback.vibrate());
      setState(() => _wrong = true);
    }
    // Ao acertar, o roteador troca a tela sozinho (redirectFor).
  }

  /// Confirma e pede o PIN novo por e-mail. O PIN antigo só deixa de valer se
  /// o servidor aceitar o envio; o PIN novo nunca aparece aqui.
  Future<void> _forgot() async {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final controller = ref.read(appLockProvider.notifier);
    final email = controller.recoveryEmail;
    if (email == null) return;
    final masked = maskEmail(email);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.pinForgotConfirmTitle),
        content: Text(l10n.pinForgotConfirmBody(masked)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.pinForgotSendAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      _sending = true;
      _recoveryFailure = null;
      _sentTo = null;
    });
    final result = await controller.forgotPin(
      recoveryLocale(locale.languageCode, locale.countryCode),
    );
    if (!mounted) return;
    setState(() {
      _sending = false;
      switch (result) {
        case Ok():
          _wrong = false;
          _sentTo = masked;
        case Err(:final failure):
          _recoveryFailure = failure;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final controller = ref.watch(appLockProvider.notifier);
    final waiting = controller.waiting;
    final remaining = controller.remainingWait;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Space.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: Space.lg),
                  PinPad(
                    message: l10n.pinLockMessage,
                    errorText: waiting
                        ? l10n.pinWaitMessage(_mmss(remaining))
                        : (_wrong ? l10n.pinWrong : null),
                    enabled: !waiting,
                    onCompleted: _submit,
                  ),
                  if (controller.biometricsEnabled && !waiting)
                    Padding(
                      padding: const EdgeInsets.only(top: Space.lg),
                      child: TextButton.icon(
                        onPressed: _tryBiometrics,
                        icon: const Icon(Icons.fingerprint),
                        label: Text(l10n.biometricsUseAction),
                      ),
                    ),
                  if (controller.canRecover) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: Space.sm),
                      child: TextButton(
                        onPressed: _sending ? null : _forgot,
                        child: _sending
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(l10n.pinForgotAction),
                      ),
                    ),
                    FailureText(_recoveryFailure),
                    if (_sentTo != null)
                      Padding(
                        padding: const EdgeInsets.only(top: Space.sm),
                        child: Semantics(
                          liveRegion: true,
                          child: Text(
                            l10n.pinForgotSent(_sentTo!),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "0:30", "15:00".
String _mmss(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
