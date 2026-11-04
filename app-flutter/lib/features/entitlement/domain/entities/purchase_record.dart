import 'store_product.dart';

/// Cópia local de uma compra que a loja confirmou. **A loja é a fonte de
/// verdade**; isto só deixa o app saber, sem rede, o que já foi confirmado.
class PurchaseRecord {
  const PurchaseRecord({required this.product, required this.since});

  final StoreProduct product;

  /// Quando o app soube da compra (não a data da loja).
  final DateTime since;

  Map<String, Object?> toJson() => {
    'product': product.id,
    'since': since.toIso8601String(),
  };

  /// Borda (arquivo): produto desconhecido ou data ilegível não conta como
  /// compra — melhor pedir "Restaurar" do que prometer um direito que não há.
  static PurchaseRecord? fromJson(Map<String, Object?> json) {
    final product = StoreProduct.byId('${json['product']}');
    final since = json['since'];
    final parsed = since is String ? DateTime.tryParse(since) : null;
    if (product == null || parsed == null) return null;
    return PurchaseRecord(product: product, since: parsed);
  }
}
