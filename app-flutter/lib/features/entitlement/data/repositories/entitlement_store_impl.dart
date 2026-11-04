import '../../../../core/storage/device_settings.dart';
import '../../domain/entities/app_entitlement.dart';
import '../../domain/repositories/entitlement_store.dart';

/// Guarda a marca no `device.json`, pelo `DeviceSettings` — escrita por
/// junção, então não mexe no PIN, na introdução nem no modo.
class EntitlementStoreImpl implements EntitlementStore {
  EntitlementStoreImpl(this._settings);

  final DeviceSettings _settings;

  static const _key = 'entitlement';

  @override
  Future<AppEntitlement?> read() async {
    final json = (await _settings.read())[_key];
    if (json is! Map) return null;
    return AppEntitlement.fromJson(json.cast<String, Object?>());
  }

  @override
  Future<void> save(AppEntitlement entitlement) =>
      _settings.merge({_key: entitlement.toJson()});
}
