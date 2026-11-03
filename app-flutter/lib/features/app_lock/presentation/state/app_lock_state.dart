import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../domain/repositories/pin_store.dart';
import '../../domain/usecases/pin_lock_rules.dart';

/// Relógio injetável: os testes trocam para simular os 30 s fora do app e a
/// contagem da espera.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Em que ponto está o bloqueio por PIN.
sealed class LockState {
  const LockState();
}

/// Ainda lendo se existe PIN. O roteador trata como a tela de espera, para o
/// conteúdo não piscar antes do bloqueio.
final class LockLoading extends LockState {
  const LockLoading();
}

/// Sem PIN: o bloqueio não existe para esta pessoa.
final class LockOff extends LockState {
  const LockOff();
}

/// Com PIN, já destravado nesta sessão.
final class LockOpen extends LockState {
  const LockOpen();
}

/// Pedindo o PIN. [waitUntil] diz até quando a espera por erros seguidos
/// segura as tentativas (null = pode tentar agora).
final class LockClosed extends LockState {
  const LockClosed({this.wrongAttempts = 0, this.waitUntil});

  final int wrongAttempts;
  final DateTime? waitUntil;
}

/// Quanto tempo fora do app faz o PIN ser pedido de novo (design.md §10): não
/// é a cada volta ao primeiro plano, senão escolher uma foto ou compartilhar
/// travaria o app na cara da pessoa.
const awayLimit = Duration(seconds: 30);

class AppLockController extends Notifier<LockState> {
  PinCredential? _credential;
  DateTime? _awaySince;

  @override
  LockState build() {
    _load();
    return const LockLoading();
  }

  bool get enabled => _credential != null;

  Future<void> _load() async {
    _credential = await ref.read(pinStoreProvider).read();
    if (!ref.mounted) return;
    // Abrir o app com PIN ativo já pede o PIN.
    state = _credential == null ? const LockOff() : const LockClosed();
  }

  /// true quando o PIN estava certo (ou quando não há bloqueio a vencer).
  bool unlock(String pin) {
    final credential = _credential;
    final closed = state;
    if (credential == null || closed is! LockClosed) return true;
    if (waiting) return false;

    if (hashPin(pin, credential.salt) == credential.hash) {
      state = const LockOpen();
      return true;
    }
    final attempts = closed.wrongAttempts + 1;
    final wait = lockoutAfter(attempts);
    state = LockClosed(
      wrongAttempts: attempts,
      waitUntil: wait == Duration.zero ? null : _now().add(wait),
    );
    return false;
  }

  /// A espera por erros seguidos ainda está valendo?
  bool get waiting {
    final closed = state;
    if (closed is! LockClosed) return false;
    final until = closed.waitUntil;
    return until != null && _now().isBefore(until);
  }

  /// Quanto falta da espera (zero quando já pode tentar).
  Duration get remainingWait {
    final closed = state;
    if (closed is! LockClosed) return Duration.zero;
    final until = closed.waitUntil;
    if (until == null) return Duration.zero;
    final left = until.difference(_now());
    return left.isNegative ? Duration.zero : left;
  }

  Future<void> enablePin(String pin) async {
    final salt = newPinSalt();
    final credential = PinCredential(salt: salt, hash: hashPin(pin, salt));
    await ref.read(pinStoreProvider).save(credential);
    _credential = credential;
    if (ref.mounted) state = const LockOpen();
  }

  /// Desativa se [pin] for o atual; devolve false se não for.
  Future<bool> disablePin(String pin) async {
    if (!matches(pin)) return false;
    await ref.read(pinStoreProvider).clear();
    _credential = null;
    if (ref.mounted) state = const LockOff();
    return true;
  }

  /// Troca o PIN se [current] for o atual; devolve false se não for.
  Future<bool> changePin({
    required String current,
    required String next,
  }) async {
    if (!matches(current)) return false;
    await enablePin(next);
    return true;
  }

  bool matches(String pin) {
    final credential = _credential;
    return credential != null &&
        hashPin(pin, credential.salt) == credential.hash;
  }

  /// O app foi para o fundo. Vale o **primeiro** aviso: a volta ao primeiro
  /// plano passa por estados intermediários (hidden, inactive) e um segundo
  /// registro zeraria o tempo fora justamente na hora de travar.
  void onAway() => _awaySince ??= _now();

  /// O app voltou: pede o PIN se ficou fora tempo demais.
  void onBack() {
    final away = _awaySince;
    _awaySince = null;
    if (away == null || !enabled) return;
    if (_now().difference(away) >= awayLimit && state is LockOpen) {
      state = const LockClosed();
    }
  }

  DateTime _now() => ref.read(clockProvider)();
}

final appLockProvider = NotifierProvider<AppLockController, LockState>(
  AppLockController.new,
);
