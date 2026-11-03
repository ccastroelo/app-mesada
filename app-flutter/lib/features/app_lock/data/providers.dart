import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/storage/providers.dart';
import '../domain/repositories/biometric_auth.dart';
import '../domain/repositories/pin_store.dart';
import 'repositories/local_auth_biometrics.dart';
import 'repositories/pin_store_impl.dart';

/// Raiz de composição da feature; os testes trocam por versões falsas.
final pinStoreProvider = Provider<PinStore>(
  (ref) => PinStoreImpl(ref.watch(deviceSettingsProvider)),
);

final biometricAuthProvider = Provider<BiometricAuth>(
  (ref) => LocalAuthBiometrics(LocalAuthentication()),
);
