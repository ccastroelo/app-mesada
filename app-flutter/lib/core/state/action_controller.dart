import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../error/failure.dart';
import '../error/result.dart';

@immutable
class ActionState {
  const ActionState({this.loading = false, this.failure});

  final bool loading;
  final Failure? failure;
}

/// Base das ações de tela (entrar, salvar, excluir...): enquanto roda mostra
/// carregando; ao falhar guarda a [Failure] para a tela traduzir em texto.
abstract class ActionController extends Notifier<ActionState> {
  @override
  ActionState build() => const ActionState();

  /// Devolve true se a ação deu certo.
  Future<bool> run(Future<Result<void>> Function() action) async {
    state = const ActionState(loading: true);
    final result = await action();
    // Ao dar certo o roteador pode já ter trocado de tela e descartado este
    // controlador.
    if (!ref.mounted) return result is Ok;
    switch (result) {
      case Ok():
        state = const ActionState();
        return true;
      case Err(:final failure):
        state = ActionState(failure: failure);
        return false;
    }
  }

  void clearFailure() => state = const ActionState();
}
