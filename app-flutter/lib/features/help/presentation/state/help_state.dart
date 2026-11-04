import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';

/// A introdução já foi vista neste aparelho? Null enquanto lê o arquivo — o
/// roteador trata isso como espera, para a introdução não piscar depois de o
/// app já ter aberto.
final introSeenProvider = FutureProvider<bool>(
  (ref) => ref.watch(introStoreProvider).seen(),
);

/// Marca como vista e atualiza quem está ouvindo (o roteador sai da
/// introdução por conta disso).
Future<void> markIntroSeen(WidgetRef ref) async {
  await ref.read(introStoreProvider).markSeen();
  ref.invalidate(introSeenProvider);
}
