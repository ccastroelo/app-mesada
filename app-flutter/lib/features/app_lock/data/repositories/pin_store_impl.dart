import '../../../../core/storage/device_settings.dart';
import '../../domain/repositories/pin_store.dart';

/// Guarda PIN e biometria no `device.json` (ADR-0017), pelo `DeviceSettings`:
/// a escrita é por junção, então ligar a biometria não apaga o PIN.
class PinStoreImpl implements PinStore {
  PinStoreImpl(this._settings);

  final DeviceSettings _settings;

  static const _salt = 'pinSalt';
  static const _hash = 'pinHash';
  static const _biometrics = 'biometricsEnabled';

  @override
  Future<PinCredential?> read() async {
    // Arquivo é borda: sem as chaves (ou ilegível) conta como "sem PIN", que é
    // o lado seguro aqui — trancar o app sem poder destravar seria pior.
    final json = await _settings.read();
    final salt = json[_salt];
    final hash = json[_hash];
    if (salt is! String || hash is! String) return null;
    return PinCredential(salt: salt, hash: hash);
  }

  @override
  Future<void> save(PinCredential credential) =>
      _settings.merge({_salt: credential.salt, _hash: credential.hash});

  @override
  Future<void> clear() =>
      _settings.merge({_salt: null, _hash: null, _biometrics: null});

  @override
  Future<bool> readBiometricsEnabled() async =>
      (await _settings.read())[_biometrics] == true;

  @override
  Future<void> saveBiometricsEnabled(bool enabled) =>
      _settings.merge({_biometrics: enabled});
}
