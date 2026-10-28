import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../rules/rules.dart';
import '../../data/providers.dart';
import '../../domain/entities/app_user.dart';
import 'gate.dart';

@immutable
class ActionState {
  const ActionState({this.loading = false, this.failure});

  final bool loading;
  final Failure? failure;
}

/// Base das ações de tela (entrar, criar família...): enquanto roda mostra
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

  AppUser? get _user => ref.read(authUserProvider).value;
}

class SignInController extends ActionController {
  Future<bool> signIn(String email, String password) => run(
    () => ref
        .read(authRepositoryProvider)
        .signInWithEmail(email.trim(), password),
  );

  Future<bool> signUp(String email, String password) => run(
    () => ref
        .read(authRepositoryProvider)
        .signUpWithEmail(email.trim(), password),
  );

  Future<bool> signInWithGoogle() =>
      run(() => ref.read(authRepositoryProvider).signInWithGoogle());

  Future<bool> sendPasswordReset(String email) => run(
    () => ref.read(authRepositoryProvider).sendPasswordReset(email.trim()),
  );
}

class CreateFamilyController extends ActionController {
  /// [languageCode] escolhe as regras-padrão (pt, en, es).
  Future<bool> create(String name, String languageCode) => run(() async {
    final user = _user;
    if (user == null) return const Err(Unexpected());
    return ref
        .read(familyRepositoryProvider)
        .createFamily(
          user: user,
          name: name,
          rules: defaultRulesFor(languageCode),
        );
  });
}

class JoinFamilyController extends ActionController {
  Future<bool> join(String code) => run(() async {
    final user = _user;
    if (user == null) return const Err(Unexpected());
    return ref
        .read(familyRepositoryProvider)
        .joinWithCode(user: user, code: code);
  });
}

class SignOutController extends ActionController {
  Future<bool> signOut() =>
      run(() => ref.read(authRepositoryProvider).signOut());
}

final signInControllerProvider =
    NotifierProvider.autoDispose<SignInController, ActionState>(
      SignInController.new,
    );

final createFamilyControllerProvider =
    NotifierProvider.autoDispose<CreateFamilyController, ActionState>(
      CreateFamilyController.new,
    );

final joinFamilyControllerProvider =
    NotifierProvider.autoDispose<JoinFamilyController, ActionState>(
      JoinFamilyController.new,
    );

final signOutControllerProvider =
    NotifierProvider.autoDispose<SignOutController, ActionState>(
      SignOutController.new,
    );

/// Gera um código de convite novo a cada vez que é lido (autoDispose: uma vez
/// por abertura do diálogo).
final inviteCodeProvider = FutureProvider.autoDispose<Result<String>>((
  ref,
) async {
  final gate = ref.read(gateProvider);
  if (gate is! GateReady) return const Err(Unexpected());
  return ref
      .read(familyRepositoryProvider)
      .createInvite(user: gate.user, family: gate.family);
});
