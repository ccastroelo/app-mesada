import '../entities/purchase_record.dart';
import '../entities/store_product.dart';

/// Onde a cópia local das compras fica no aparelho.
abstract class PurchaseStore {
  /// As compras já confirmadas, por produto. Vazio se não há nenhuma.
  Future<Map<StoreProduct, PurchaseRecord>> read();

  Future<void> save(PurchaseRecord record);

  /// A última volta ao modo local foi por **vencimento** da assinatura de
  /// compartilhar (ADR-0022)? É o que deixa Ajustes explicar o que houve.
  Future<bool> sharingLapsed();

  Future<void> setSharingLapsed(bool lapsed);
}
