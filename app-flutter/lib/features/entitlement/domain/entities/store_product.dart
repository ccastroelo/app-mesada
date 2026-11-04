/// Os dois produtos que existem nas lojas (ADR-0021). **Os ids têm de ser
/// criados iguais no App Store Connect e no Google Play e nunca podem ser
/// removidos**: "restaurar compras" depende deles.
enum StoreProduct {
  /// Compra única, não-consumível: libera o app neste aparelho para sempre.
  app('mesada_app'),

  /// Assinatura auto-renovável, uma por família: libera a sincronização.
  sharing('mesada_compartilhar');

  const StoreProduct(this.id);

  final String id;

  bool get isSubscription => this == StoreProduct.sharing;

  static StoreProduct? byId(String id) {
    for (final product in values) {
      if (product.id == id) return product;
    }
    return null;
  }
}
