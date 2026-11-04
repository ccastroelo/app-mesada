import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

import '../../domain/entities/family_plan.dart';
import '../../domain/repositories/plan_gateway.dart';

/// A loja pelo `in_app_purchase`. Produto **não-consumível**: uma compra por
/// família, sem renovação (ADR-0020).
///
/// A loja responde pelo `purchaseStream`, não pelo retorno da chamada — então
/// comprar e restaurar disparam a ação e esperam a confirmação do **nosso**
/// produto chegar pelo stream.
class InAppPurchasePlanGateway implements PlanGateway {
  InAppPurchasePlanGateway(this._iap);

  final InAppPurchase _iap;

  /// Quanto esperar pela loja antes de desistir: diálogo fechado por fora,
  /// loja fora do ar, pagamento pendente de aprovação.
  static const _patience = Duration(minutes: 2);

  @override
  Future<PlanOffer?> offer() async {
    try {
      if (!await _iap.isAvailable()) return null;
      final response = await _iap.queryProductDetails({
        FamilyPlan.lifetimeProductId,
      });
      if (response.productDetails.isEmpty) return null;
      final details = response.productDetails.first;
      // O preço vem formatado pela loja, na moeda da conta.
      return PlanOffer(productId: details.id, price: details.price);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> buy() => _awaitStore(() async {
    final response = await _iap.queryProductDetails({
      FamilyPlan.lifetimeProductId,
    });
    if (response.productDetails.isEmpty) return false;
    return _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(
        productDetails: response.productDetails.first,
      ),
    );
  });

  @override
  Future<bool> restore() => _awaitStore(() async {
    await _iap.restorePurchases();
    return true;
  });

  Future<bool> _awaitStore(Future<bool> Function() start) async {
    final answer = Completer<bool>();
    final subscription = _iap.purchaseStream.listen((purchases) async {
      for (final purchase in purchases) {
        if (purchase.productID != FamilyPlan.lifetimeProductId) continue;
        switch (purchase.status) {
          case PurchaseStatus.purchased || PurchaseStatus.restored:
            // Sem isto a loja repete a entrega a cada abertura.
            if (purchase.pendingCompletePurchase) {
              await _iap.completePurchase(purchase);
            }
            if (!answer.isCompleted) answer.complete(true);
          case PurchaseStatus.error || PurchaseStatus.canceled:
            if (!answer.isCompleted) answer.complete(false);
          case PurchaseStatus.pending:
            break;
        }
      }
    });
    try {
      if (!await start()) return false;
      return await answer.future.timeout(_patience, onTimeout: () => false);
    } catch (_) {
      return false;
    } finally {
      await subscription.cancel();
    }
  }
}
