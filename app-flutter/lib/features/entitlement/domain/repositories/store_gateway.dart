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

  /// O que o validador reconhece **agora** (ADR-0022), para o dono em uso.
  ///
  /// Null quer dizer **não sei** — sem rede, sem chave, validador fora do ar —
  /// e é diferente de um conjunto vazio, que é "não tem nada". Quem pergunta
  /// decide o que fazer com a dúvida.
  Future<Set<StoreProduct>?> active();

  /// Passa a consultar e comprar em nome da família [familyId].
  ///
  /// É assim que o **convidado** vê a assinatura que o outro responsável pagou:
  /// os dois aparelhos usam o id da família como dono no validador (ADR-0022).
  /// Nulo volta ao dono anônimo deste aparelho.
  Future<void> useFamily(String? familyId);
}
