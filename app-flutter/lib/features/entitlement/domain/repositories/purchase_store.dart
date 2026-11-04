import '../entities/purchase_record.dart';
import '../entities/store_product.dart';

/// Onde a cópia local das compras fica no aparelho.
abstract class PurchaseStore {
  /// As compras já confirmadas, por produto. Vazio se não há nenhuma.
  Future<Map<StoreProduct, PurchaseRecord>> read();

  Future<void> save(PurchaseRecord record);
}
