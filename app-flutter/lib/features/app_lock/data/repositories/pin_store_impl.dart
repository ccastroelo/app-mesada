import '../../../../core/storage/device_settings.dart';
import '../../domain/repositories/pin_store.dart';
import '../../domain/usecases/pin_lock_rules.dart';

/// Guarda PIN e biometria no `device.json` (ADR-0017), pelo `DeviceSettings`:
/// a escrita é por junção, então ligar a biometria não apaga o PIN.
class PinStoreImpl implements PinStore {
  PinStoreImpl(this._settings);

  final DeviceSettings _settings;

  static const _salt = 'pinSalt';
  static const _hash = 'pinHash';
  static const _biometrics = 'biometricsEnabled';
  static const _recoveryEmail = 'recoveryEmail';
  static const _recoveryToken = 'recoveryToken';
  static const _installId = 'installId';

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
  Future<void> clear() => _settings.merge({
    _salt: null,
    _hash: null,
    _biometrics: null,
    _recoveryEmail: null,
    _recoveryToken: null,
  });

  @override
  Future<PinRecovery?> readRecovery() async {
    final json = await _settings.read();
    final email = json[_recoveryEmail];
    final token = json[_recoveryToken];
    final installId = json[_installId];
    if (email is! String || token is! String || installId is! String) {
      return null;
    }
    return PinRecovery(email: email, token: token, installId: installId);
  }

  @override
  Future<void> saveRecovery(PinRecovery recovery) => _settings.merge({
    _recoveryEmail: recovery.email,
    _recoveryToken: recovery.token,
    _installId: recovery.installId,
  });

  @override
  Future<String> readOrCreateInstallId() async {
    final existing = (await _settings.read())[_installId];
    if (existing is String && existing.isNotEmpty) return existing;
    final created = newInstallId();
    await _settings.merge({_installId: created});
    return created;
  }

  @override
  Future<bool> readBiometricsEnabled() async =>
      (await _settings.read())[_biometrics] == true;

  @override
  Future<void> saveBiometricsEnabled(bool enabled) =>
      _settings.merge({_biometrics: enabled});
}
