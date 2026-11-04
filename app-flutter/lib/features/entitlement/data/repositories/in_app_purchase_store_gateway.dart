import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

import '../../domain/entities/store_product.dart';
import '../../domain/repositories/store_gateway.dart';

/// A loja pelo `in_app_purchase`: o app é **não-consumível** e o
/// compartilhamento é **assinatura** (ADR-0021).
///
/// A loja responde pelo `purchaseStream`, não pelo retorno da chamada — então
/// comprar e restaurar disparam a ação e esperam a confirmação do **nosso**
/// produto chegar pelo stream.
class InAppPurchaseStoreGateway implements StoreGateway {
  InAppPurchaseStoreGateway(this._iap);

  final InAppPurchase _iap;

  /// Quanto esperar pela loja antes de desistir: diálogo fechado por fora,
  /// loja fora do ar, pagamento pendente de aprovação.
  static const _patience = Duration(minutes: 2);

  @override
  Future<StoreOffer?> offer(StoreProduct product) async {
    try {
      if (!await _iap.isAvailable()) return null;
      final response = await _iap.queryProductDetails({product.id});
      if (response.productDetails.isEmpty) return null;
      // O preço vem formatado pela loja, na moeda da conta.
      return StoreOffer(
        product: product,
        price: response.productDetails.first.price,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> buy(StoreProduct product) async {
    final confirmed = await _awaitStore(
      wanted: {product},
      start: () async {
        final response = await _iap.queryProductDetails({product.id});
        if (response.productDetails.isEmpty) return false;
        // O plugin usa `buyNonConsumable` tanto para não-consumível quanto para
        // assinatura; só consumível tem chamada própria.
        return _iap.buyNonConsumable(
          purchaseParam: PurchaseParam(
            productDetails: response.productDetails.first,
          ),
        );
      },
    );
    return confirmed.contains(product);
  }

  @override
  Future<Set<StoreProduct>> restore() => _awaitStore(
    wanted: StoreProduct.values.toSet(),
    start: () async {
      await _iap.restorePurchases();
      return true;
    },
  );

  /// Dispara [start] e junta o que a loja confirmar, entre os [wanted], até
  /// vir tudo, vir um erro/cancelamento ou acabar a paciência.
  Future<Set<StoreProduct>> _awaitStore({
    required Set<StoreProduct> wanted,
    required Future<bool> Function() start,
  }) async {
    final found = <StoreProduct>{};
    final done = Completer<void>();
    final subscription = _iap.purchaseStream.listen((purchases) async {
      for (final purchase in purchases) {
        final product = StoreProduct.byId(purchase.productID);
        if (product == null || !wanted.contains(product)) continue;
        switch (purchase.status) {
          case PurchaseStatus.purchased || PurchaseStatus.restored:
            // Sem isto a loja repete a entrega a cada abertura.
            if (purchase.pendingCompletePurchase) {
              await _iap.completePurchase(purchase);
            }
            found.add(product);
          case PurchaseStatus.error || PurchaseStatus.canceled:
            if (!done.isCompleted) done.complete();
          case PurchaseStatus.pending:
            break;
        }
      }
      if (found.isNotEmpty && !done.isCompleted) {
        // Uma compra pontual termina na confirmação; a restauração junta tudo
        // o que vier junto, então dá um instante para o resto chegar.
        Timer(
          wanted.length == 1 ? Duration.zero : const Duration(seconds: 2),
          () {
            if (!done.isCompleted) done.complete();
          },
        );
      }
    });
    try {
      if (!await start()) return const {};
      await done.future.timeout(_patience, onTimeout: () {});
      return found;
    } catch (_) {
      return found;
    } finally {
      await subscription.cancel();
    }
  }
}
