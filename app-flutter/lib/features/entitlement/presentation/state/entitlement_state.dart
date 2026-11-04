import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app_lock/app_lock_providers.dart';
import '../../data/providers.dart';
import '../../domain/entities/app_entitlement.dart';

/// A marca do app neste aparelho. Se ainda não existe, é o **primeiro uso**:
/// grava agora a data (início do teste), o modelo de venda desta versão e a
/// origem — atualização do app antigo ou instalação nova (ADR-0021). Depois
/// disso nunca é reescrita: a data, o modelo e a origem ficam como foram no
/// começo.
final entitlementProvider = FutureProvider<AppEntitlement>((ref) async {
  final store = ref.watch(entitlementStoreProvider);
  final existing = await store.read();
  if (existing != null) return existing;
  final existed = await ref.read(legacyAppDetectorProvider).existed();
  final created = AppEntitlement(
    since: ref.read(clockProvider)(),
    origin: existed
        ? EntitlementOrigin.legacyUpdate
        : EntitlementOrigin.newInstall,
  );
  await store.save(created);
  return created;
});
