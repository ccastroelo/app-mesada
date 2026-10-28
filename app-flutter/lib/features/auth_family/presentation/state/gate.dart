import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/family.dart';

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

final class GateReady extends Gate {
  const GateReady(this.user, this.family);

  final AppUser user;
  final Family family;
}

final gateProvider = Provider<Gate>((ref) {
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
  return GateReady(user, value);
});
