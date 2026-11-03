import 'package:local_auth/local_auth.dart';

import '../../domain/repositories/biometric_auth.dart';

/// Biometria pelo `local_auth` (BiometricPrompt no Android, Face ID/Touch ID
/// no iOS). Qualquer erro da plataforma conta como "não reconheceu": a tela
/// cai na reserva, que é o PIN do app.
class LocalAuthBiometrics implements BiometricAuth {
  LocalAuthBiometrics(this._auth);

  final LocalAuthentication _auth;

  @override
  Future<bool> isAvailable() async {
    try {
      return await _auth.isDeviceSupported() && await _auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        // Só biometria: o código do aparelho **não** serve de reserva, já que
        // o filho costuma saber (ADR-0018). A reserva é o PIN do app.
        biometricOnly: true,
        // O diálogo sobrevive ao app ir para o fundo e voltar.
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}
