import '../../../../core/storage/device_settings.dart';
import '../../domain/repositories/intro_store.dart';

/// Guarda a marca no `device.json`, pelo `DeviceSettings` — a escrita é por
/// junção, então isso não mexe no PIN nem na biometria (ADR-0017).
class IntroStoreImpl implements IntroStore {
  IntroStoreImpl(this._settings);

  final DeviceSettings _settings;

  static const _key = 'introSeen';

  @override
  Future<bool> seen() async => (await _settings.read())[_key] == true;

  @override
  Future<void> markSeen() => _settings.merge({_key: true});
}
