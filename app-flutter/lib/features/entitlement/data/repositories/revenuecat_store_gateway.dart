import 'dart:io';

import 'package:purchases_flutter/purchases_flutter.dart' as rc;

import '../../domain/entities/store_product.dart';
import '../../domain/repositories/store_gateway.dart';

/// A loja pelo RevenueCat (ADR-0022), que confere os recibos da App Store e do
/// Google Play. É ele que permite ao **convidado** ver a assinatura paga pelo
/// outro responsável: os dois aparelhos consultam o mesmo dono, o id da
/// família.
///
/// No RevenueCat, o *entitlement* de cada produto tem de se chamar **igual ao
/// id do produto** (`mesada_app`, `mesada_compartilhar`) — é por esse nome que
/// o app reconhece o direito.
///
/// Sem chave (`--dart-define`), o gateway fica **desligado**: a oferta volta
/// nula, comprar falha e o direito ativo é "não sei". O app segue valendo pelo
/// teste e pelas compras já guardadas no aparelho.
class RevenueCatStoreGateway implements StoreGateway {
  RevenueCatStoreGateway({String? androidKey, String? iosKey})
    : _androidKey = androidKey ?? _androidKeyFromBuild,
      _iosKey = iosKey ?? _iosKeyFromBuild;

  /// As chaves públicas do SDK entram no build, nunca no git (ADR-0022).
  static const _androidKeyFromBuild = String.fromEnvironment(
    'REVENUECAT_KEY_ANDROID',
  );
  static const _iosKeyFromBuild = String.fromEnvironment('REVENUECAT_KEY_IOS');

  final String _androidKey;
  final String _iosKey;

  bool _configured = false;
  String? _familyId;

  String get _key => Platform.isIOS || Platform.isMacOS ? _iosKey : _androidKey;

  /// Configura na primeira necessidade. Sem chave não tenta nada: o app não
  /// pode quebrar por falta de configuração de loja.
  Future<bool> _ready() async {
    if (_key.isEmpty) return false;
    if (_configured) return true;
    try {
      await rc.Purchases.configure(rc.PurchasesConfiguration(_key));
      _configured = true;
      if (_familyId != null) await _logIn(_familyId!);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _logIn(String familyId) async {
    await rc.Purchases.logIn(familyId);
    // A assinatura pode ter sido comprada antes de a família existir (o fluxo
    // do ADR-0021 vende primeiro). Sincronizar aqui pede ao validador que
    // reveja os recibos deste aparelho sob o dono novo.
    await rc.Purchases.syncPurchasesForResult();
  }

  @override
  Future<void> useFamily(String? familyId) async {
    if (_familyId == familyId) return;
    _familyId = familyId;
    if (!await _ready()) return;
    try {
      if (familyId == null) {
        await rc.Purchases.logOut();
      } else {
        await _logIn(familyId);
      }
    } catch (_) {
      // Já anônimo, sem rede, dono desconhecido: segue com o que havia.
    }
  }

  @override
  Future<StoreOffer?> offer(StoreProduct product) async {
    if (!await _ready()) return null;
    try {
      final found = await _find(product);
      // O preço vem formatado pelo validador, na moeda da conta.
      return found == null
          ? null
          : StoreOffer(product: product, price: found.priceString);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> buy(StoreProduct product) async {
    if (!await _ready()) return false;
    try {
      final found = await _find(product);
      if (found == null) return false;
      final result = await rc.Purchases.purchase(
        rc.PurchaseParams.storeProduct(found),
      );
      return _productsOf(result.customerInfo).contains(product);
    } catch (_) {
      // Compra cancelada, recusada ou pendente de aprovação: não liberou.
      return false;
    }
  }

  @override
  Future<Set<StoreProduct>> restore() async {
    if (!await _ready()) return const {};
    try {
      return _productsOf(await rc.Purchases.restorePurchases());
    } catch (_) {
      return const {};
    }
  }

  @override
  Future<Set<StoreProduct>?> active() async {
    if (!await _ready()) return null;
    try {
      return _productsOf(await rc.Purchases.getCustomerInfo());
    } catch (_) {
      // Sem resposta é "não sei", não "não tem".
      return null;
    }
  }

  Future<rc.StoreProduct?> _find(StoreProduct product) async {
    final found = await rc.Purchases.getProducts(
      [product.id],
      productCategory: product.isSubscription
          ? rc.ProductCategory.subscription
          : rc.ProductCategory.nonSubscription,
    );
    return found.isEmpty ? null : found.first;
  }

  /// Os direitos ativos, traduzidos para os nossos produtos.
  Set<StoreProduct> _productsOf(rc.CustomerInfo info) => {
    for (final id in info.entitlements.active.keys) ?StoreProduct.byId(id),
  };
}
