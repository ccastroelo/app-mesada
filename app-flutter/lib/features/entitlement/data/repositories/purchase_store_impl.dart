import '../../../../core/storage/device_settings.dart';
import '../../domain/entities/purchase_record.dart';
import '../../domain/entities/store_product.dart';
import '../../domain/repositories/purchase_store.dart';

/// Guarda as compras no `device.json`, pelo `DeviceSettings` — escrita por
/// junção, então não mexe no PIN, na marca do app nem no modo.
class PurchaseStoreImpl implements PurchaseStore {
  PurchaseStoreImpl(this._settings);

  final DeviceSettings _settings;

  static const _key = 'purchases';
  static const _lapsedKey = 'sharingLapsed';

  @override
  Future<Map<StoreProduct, PurchaseRecord>> read() async {
    final json = (await _settings.read())[_key];
    if (json is! Map) return <StoreProduct, PurchaseRecord>{};
    final records = <StoreProduct, PurchaseRecord>{};
    for (final value in json.values) {
      if (value is! Map) continue;
      final record = PurchaseRecord.fromJson(value.cast<String, Object?>());
      if (record != null) records[record.product] = record;
    }
    return records;
  }

  @override
  Future<void> save(PurchaseRecord record) async {
    // Lê o que há e devolve tudo junto: `merge` troca a chave inteira.
    final current = await read();
    current[record.product] = record;
    await _settings.merge({
      _key: {
        for (final entry in current.entries) entry.key.id: entry.value.toJson(),
      },
    });
  }

  @override
  Future<bool> sharingLapsed() async =>
      (await _settings.read())[_lapsedKey] == true;

  @override
  Future<void> setSharingLapsed(bool lapsed) =>
      _settings.merge({_lapsedKey: lapsed});
}
