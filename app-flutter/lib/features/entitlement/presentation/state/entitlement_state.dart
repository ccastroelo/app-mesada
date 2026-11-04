import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/state/action_controller.dart';
import '../../../app_lock/app_lock_providers.dart';
import '../../data/providers.dart';
import '../../domain/entities/app_entitlement.dart';
import '../../domain/entities/purchase_record.dart';
import '../../domain/entities/store_product.dart';
import '../../domain/repositories/store_gateway.dart';
import '../../domain/usecases/evaluate_access.dart';

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

/// As compras que a loja já confirmou, na cópia deste aparelho.
final purchasesProvider = FutureProvider<Map<StoreProduct, PurchaseRecord>>(
  (ref) => ref.watch(purchaseStoreProvider).read(),
);

/// O que o app pode fazer agora: teste, comprado, app antigo ou só leitura
/// (ADR-0021). Recalculado quando a compra muda e ao voltar ao app (o teste
/// pode ter acabado enquanto estava em segundo plano).
final accessProvider = FutureProvider<AppAccess>((ref) async {
  final entitlement = await ref.watch(entitlementProvider.future);
  final purchases = await ref.watch(purchasesProvider.future);
  final clock = ref.read(clockProvider)();
  // Atrasar o relógio não devolve dias de teste: vale o maior instante já
  // visto. Guardar esse instante é só reforço, então uma falha de gravação não
  // pode trancar quem tem direito.
  final seen = entitlement.markSeen(clock);
  if (!identical(seen, entitlement)) {
    try {
      await ref.read(entitlementStoreProvider).save(seen);
    } catch (_) {}
  }
  return evaluateAccess(
    entitlement: entitlement,
    ownsApp: purchases.containsKey(StoreProduct.app),
    now: entitlement.effectiveNow(clock),
  );
});

/// Para ligar e desligar controles de escrita. Enquanto o acesso carrega não
/// bloqueia: um instante de dúvida não pode trancar a tela; quem de fato
/// impede a gravação é a guarda [canWriteNow].
final canWriteProvider = Provider<bool>(
  (ref) => ref.watch(accessProvider).value?.canWrite ?? true,
);

/// A família já tem a assinatura de compartilhar neste aparelho?
///
/// **Limite conhecido (ADR-0021):** a cópia local não sabe quando a assinatura
/// vence; sem validação no servidor, ela vale como ativa depois de comprada.
final sharingSubscribedProvider = Provider<bool>(
  (ref) =>
      ref.watch(purchasesProvider).value?.containsKey(StoreProduct.sharing) ??
      false,
);

/// O preço e a oferta de um produto, como a loja respondeu.
final storeOfferProvider = FutureProvider.family<StoreOffer?, StoreProduct>(
  (ref, product) => ref.watch(storeGatewayProvider).offer(product),
);

/// Comprar e restaurar. A loja é a fonte de verdade; aqui só se guarda a cópia.
class PurchaseActions extends ActionController {
  /// true quando a loja confirmou.
  Future<bool> buy(StoreProduct product) async {
    state = const ActionState(loading: true);
    final ok = await ref.read(storeGatewayProvider).buy(product);
    if (ok) await _remember({product});
    if (ref.mounted) state = const ActionState();
    return ok;
  }

  /// true quando a loja devolveu ao menos uma das nossas compras.
  Future<bool> restore() async {
    state = const ActionState(loading: true);
    final found = await ref.read(storeGatewayProvider).restore();
    await _remember(found);
    if (ref.mounted) state = const ActionState();
    return found.isNotEmpty;
  }

  Future<void> _remember(Set<StoreProduct> products) async {
    if (products.isEmpty) return;
    final store = ref.read(purchaseStoreProvider);
    final now = ref.read(clockProvider)();
    for (final product in products) {
      await store.save(PurchaseRecord(product: product, since: now));
    }
    if (ref.mounted) ref.invalidate(purchasesProvider);
  }
}

final purchaseActionsProvider =
    NotifierProvider.autoDispose<PurchaseActions, ActionState>(
      PurchaseActions.new,
    );

/// Guarda das escritas: só leitura não grava. Se o acesso não puder ser lido,
/// deixa passar — um erro de leitura não pode trancar quem tem direito.
Future<bool> canWriteNow(Ref ref) async {
  try {
    return (await ref.read(accessProvider.future)).canWrite;
  } catch (_) {
    return true;
  }
}
