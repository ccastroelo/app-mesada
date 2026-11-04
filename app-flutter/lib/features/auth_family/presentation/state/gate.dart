import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/app_mode_state.dart';
import '../../../../core/storage/providers.dart';
import '../../data/providers.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/family.dart';

/// Família do aparelho (modo local, ADR-0014): existe sempre, sem conta.
final localFamilyProvider = StreamProvider<Family>(
  (ref) => ref.watch(localFamilySourceProvider).watchFamily(),
);

final authUserProvider = StreamProvider<AppUser?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);

final familyIdProvider = StreamProvider<String?>((ref) {
  final user = ref.watch(authUserProvider).value;
  if (user == null) return Stream.value(null);
  return ref.watch(familyRepositoryProvider).watchFamilyId(user.uid);
});

final familyProvider = StreamProvider<Family?>((ref) {
  final familyId = ref.watch(familyIdProvider).value;
  if (familyId == null) return Stream.value(null);
  return ref.watch(familyRepositoryProvider).watchFamily(familyId);
});

/// Em que ponto da entrada a pessoa está. O roteador decide a tela por aqui.
sealed class Gate {
  const Gate();
}

final class GateLoading extends Gate {
  const GateLoading();
}

final class GateError extends Gate {
  const GateError(this.error);

  final Object error;
}

final class GateSignedOut extends Gate {
  const GateSignedOut();
}

final class GateNeedsFamily extends Gate {
  const GateNeedsFamily(this.user);

  final AppUser user;
}

/// Pronto para usar o app. [user] é nulo no modo local, onde não há conta
/// (ADR-0015): quem precisa de identidade (convite) checa isso.
final class GateReady extends Gate {
  const GateReady(this.family, {this.user});

  final Family family;
  final AppUser? user;
}

/// No modo local a família vem do arquivo e não há login a esperar; no modo
/// nuvem (assinatura) vale a composição auth → família (ADR-0014).
final gateProvider = Provider<Gate>((ref) {
  // Sem saber de onde vêm os dados, não há conteúdo a mostrar (ADR-0014).
  if (ref.watch(savedModeProvider).isLoading) return const GateLoading();
  return switch (ref.watch(appModeProvider)) {
    AppMode.local => _localGate(ref),
    AppMode.cloud => _cloudGate(ref),
  };
});

Gate _localGate(Ref ref) {
  final family = ref.watch(localFamilyProvider);
  if (family.hasError) return GateError(family.error!);
  if (family.isLoading || !family.hasValue) return const GateLoading();
  return GateReady(family.value!);
}

Gate _cloudGate(Ref ref) {
  final auth = ref.watch(authUserProvider);
  if (auth.hasError) return GateError(auth.error!);
  if (auth.isLoading || !auth.hasValue) return const GateLoading();
  final user = auth.value;
  if (user == null) return const GateSignedOut();

  final familyId = ref.watch(familyIdProvider);
  if (familyId.hasError) return GateError(familyId.error!);
  if (familyId.isLoading || !familyId.hasValue) return const GateLoading();
  if (familyId.value == null) return GateNeedsFamily(user);

  final family = ref.watch(familyProvider);
  if (family.hasError) return GateError(family.error!);
  if (family.isLoading || !family.hasValue) return const GateLoading();
  final value = family.value;
  if (value == null) return GateNeedsFamily(user);
  return GateReady(value, user: user);
}
