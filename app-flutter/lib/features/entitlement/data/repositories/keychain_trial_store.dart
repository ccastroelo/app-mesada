import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/repositories/secure_trial_store.dart';

/// O início do teste no cofre do sistema (ADR-0024): **Keychain** no iOS, onde
/// na prática sobrevive a apagar o app, e `EncryptedSharedPreferences` no
/// Android, onde **não** sobrevive — ali o valor some com a desinstalação e o
/// furo continua aberto de propósito (ADR-0021).
///
/// Nada aqui pode impedir o app de abrir: toda falha vira "não sei" (nulo) na
/// leitura e é engolida na gravação.
class KeychainTrialStore implements SecureTrialStore {
  KeychainTrialStore([FlutterSecureStorage? storage])
    : _storage =
          storage ??
          const FlutterSecureStorage(
            // `first_unlock` (e não `..._this_device`) deixa o valor voltar
            // num restauro de backup: o teste continua de onde estava, em vez
            // de recomeçar em aparelho novo.
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
            mOptions: MacOsOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  final FlutterSecureStorage _storage;

  static const _key = 'trialSince';

  @override
  Future<DateTime?> read() async {
    try {
      final value = await _storage.read(key: _key);
      return value == null ? null : DateTime.tryParse(value);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(DateTime since) async {
    try {
      await _storage.write(key: _key, value: since.toIso8601String());
    } catch (_) {}
  }
}
