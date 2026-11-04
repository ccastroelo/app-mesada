import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/storage/providers.dart';
import '../domain/repositories/biometric_auth.dart';
import '../domain/repositories/pin_recovery_service.dart';
import '../domain/repositories/pin_store.dart';
import 'repositories/http_pin_recovery_service.dart';
import 'repositories/local_auth_biometrics.dart';
import 'repositories/pin_store_impl.dart';

/// Raiz de composição da feature; os testes trocam por versões falsas.
final pinStoreProvider = Provider<PinStore>(
  (ref) => PinStoreImpl(ref.watch(deviceSettingsProvider)),
);

/// A URL do servidor vem de `--dart-define=RECOVERY_URL=...` (ADR-0023), fora
/// do Git. Vazia, o "esqueci o PIN" não aparece.
const _recoveryUrl = String.fromEnvironment('RECOVERY_URL');

final pinRecoveryServiceProvider = Provider<PinRecoveryService>(
  (ref) => HttpPinRecoveryService(_recoveryUrl),
);

final biometricAuthProvider = Provider<BiometricAuth>(
  (ref) => LocalAuthBiometrics(LocalAuthentication()),
);
