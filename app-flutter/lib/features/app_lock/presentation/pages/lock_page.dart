import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../l10n/app_localizations.dart';
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
