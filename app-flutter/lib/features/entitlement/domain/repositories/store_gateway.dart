import '../entities/store_product.dart';

/// O que a loja oferece: o produto e o preço **já formatado por ela**, na
/// moeda da conta de quem está comprando.
class StoreOffer {
  const StoreOffer({required this.product, required this.price});

  final StoreProduct product;
  final String price;
}

/// A loja (App Store / Google Play). É a **fonte de verdade** do que a pessoa
/// comprou (ADR-0021); o aparelho guarda só uma cópia.
abstract class StoreGateway {
  /// A oferta, ou null quando a loja não respondeu ou não tem o produto.
  Future<StoreOffer?> offer(StoreProduct product);

  /// Abre a compra. true quando a loja confirmou.
  Future<bool> buy(StoreProduct product);

  /// Procura as compras da conta da loja e devolve as dos nossos produtos.
  Future<Set<StoreProduct>> restore();
}
