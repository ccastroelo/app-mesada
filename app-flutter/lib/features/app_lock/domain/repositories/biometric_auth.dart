/// Biometria do aparelho (Face ID, digital, rosto).
///
/// O PIN continua existindo como **reserva**: biometria falha, aparelho troca,
/// dedo molhado. E a reserva é o PIN do app, não o código do aparelho — que o
/// filho normalmente conhece (ADR-0018).
abstract class BiometricAuth {
  /// O aparelho tem biometria cadastrada e pronta para usar?
  Future<bool> isAvailable();

  /// Pede a biometria, mostrando [reason] no diálogo do sistema.
  /// true quando reconheceu; false se falhou, foi cancelada ou deu erro.
  Future<bool> authenticate(String reason);
}
