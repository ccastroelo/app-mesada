/// O que a loja oferece: o produto e o preço **já formatado por ela**, na
/// moeda da conta de quem está comprando.
class PlanOffer {
  const PlanOffer({required this.productId, required this.price});

  final String productId;
  final String price;
}

/// A loja (App Store / Google Play). É a **fonte de verdade** do direito
/// (ADR-0020): o aparelho e o documento da família são cópias.
abstract class PlanGateway {
  /// A oferta, ou null quando a loja não respondeu ou não tem o produto.
  Future<PlanOffer?> offer();

  /// Abre a compra. true quando a loja confirmou.
  Future<bool> buy();

  /// Procura a compra única na conta da loja. true quando achou.
  Future<bool> restore();
}
