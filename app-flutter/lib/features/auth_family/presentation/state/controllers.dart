import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/state/action_controller.dart';
import '../../../../core/storage/app_mode_state.dart';
import '../../../../core/storage/local_document.dart';
import '../../../../core/storage/providers.dart';
import '../../../rules/rules.dart';
import '../../data/providers.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/family_snapshot.dart';
import 'gate.dart';

AppUser? _currentUser(Ref ref) => ref.read(authUserProvider).value;

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
    final user = _currentUser(ref);
    if (user == null) return const Err(Unexpected());

    // Quem chegou aqui vindo do uso local **já tem dados**: a família nasce
    // com eles, não com as 20 regras-padrão. É a virada de fonte de verdade
    // do ADR-0014, e ela acontece uma vez só.
    final document = await ref.read(localStoreProvider).watch().first;
    final hasLocalData =
        document.children.isNotEmpty || document.rules.isNotEmpty;
    if (hasLocalData) {
      return ref
          .read(familyRepositoryProvider)
          .createFamilyFromLocal(
            user: user,
            name: name,
            children: document.children,
            rules: document.rules,
            entries: document.entries,
          );
    }

    return ref
        .read(familyRepositoryProvider)
        .createFamily(
          user: user,
          name: name,
          rules: defaultRulesFor(languageCode),
        );
  });
}

/// Deixa de compartilhar neste aparelho: baixa um retrato da família para o
/// arquivo local e só então troca o modo (ADR-0014, "ao cancelar, baixa um
/// retrato"). A ordem importa: se baixar ou gravar falhar, o modo não muda e a
/// pessoa segue na nuvem com tudo intacto. Nada é apagado na nuvem, e o outro
/// responsável continua nela.
class BackToLocalController extends ActionController {
  Future<bool> leave() => run(() async {
    final gate = ref.read(gateProvider);
    if (gate is! GateReady) return const Err(Unexpected());
    final downloaded = await ref
        .read(familyRepositoryProvider)
        .downloadSnapshot(gate.family.id);
    final FamilySnapshot snapshot;
    switch (downloaded) {
      case Ok(:final value):
        snapshot = value;
      case Err(:final failure):
        return Err(failure);
    }

    final saved = await ref
        .read(localStoreProvider)
        .update(
          (_) => LocalDocument(
            family: {'id': LocalDocument.localFamilyId, 'name': snapshot.name},
            children: snapshot.children,
            rules: snapshot.rules,
            entries: snapshot.entries,
          ),
        );
    if (saved is Err) return saved;

    await ref.read(deviceSettingsProvider).merge({'mode': AppMode.local.name});
    ref.invalidate(savedModeProvider);
    return const Ok(null);
  });
}

/// Nome da família no modo local (ADR-0014): só grava no arquivo do aparelho.
class RenameLocalFamilyController extends ActionController {
  Future<bool> rename(String name) =>
      run(() => ref.read(localFamilySourceProvider).rename(name));
}

/// Saída da tela de erro quando o arquivo local está ilegível: guarda o ruim
/// como `.bak` e recomeça vazio. Só faz sentido no modo local.
class StartOverController extends ActionController {
  Future<bool> startOver() => run(() async {
    final result = await ref.read(localFamilySourceProvider).startOver();
    // A leitura que falhou deixou o stream da família em erro: reabre.
    if (result is Ok && ref.mounted) ref.invalidate(localFamilyProvider);
    return result;
  });
}

class JoinFamilyController extends ActionController {
  Future<bool> join(String code) => run(() async {
    final user = _currentUser(ref);
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

final renameLocalFamilyControllerProvider =
    NotifierProvider.autoDispose<RenameLocalFamilyController, ActionState>(
      RenameLocalFamilyController.new,
    );

final startOverControllerProvider =
    NotifierProvider.autoDispose<StartOverController, ActionState>(
      StartOverController.new,
    );

final backToLocalControllerProvider =
    NotifierProvider.autoDispose<BackToLocalController, ActionState>(
      BackToLocalController.new,
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
  final user = gate.user;
  if (user == null) return const Err(Unexpected());
  return ref
      .read(familyRepositoryProvider)
      .createInvite(user: user, family: gate.family);
});
