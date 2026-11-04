/// O PIN guardado: sal e hash (nunca o PIN em si).
class PinCredential {
  const PinCredential({required this.salt, required this.hash});

  final String salt;
  final String hash;
}

/// O e-mail de recuperação registrado no servidor (ADR-0023) e o token que
/// prova o registro. Do aparelho, como o PIN.
class PinRecovery {
  const PinRecovery({
    required this.email,
    required this.token,
    required this.installId,
  });

  final String email;
  final String token;
  final String installId;
}

/// Onde moram os ajustes do bloqueio: o PIN e o liga/desliga da biometria.
/// São **do aparelho**, não da família (design.md §4.11): ficam num arquivo
/// separado do `mesada.json` para nunca subir junto com os dados na
/// assinatura (ADR-0014/0017).
abstract class PinStore {
  /// A credencial guardada, ou null quando o PIN está desativado.
  Future<PinCredential?> read();

  Future<void> save(PinCredential credential);

  /// Apaga o PIN, o e-mail de recuperação **e** desliga a biometria: sem PIN
  /// não há reserva nem o que recuperar.
  Future<void> clear();

  /// O e-mail de recuperação, ou null quando não há.
  Future<PinRecovery?> readRecovery();

  Future<void> saveRecovery(PinRecovery recovery);

  /// Identificador deste aparelho para o servidor. Nasce na primeira vez e
  /// fica; não é dado pessoal.
  Future<String> readOrCreateInstallId();

  Future<bool> readBiometricsEnabled();

  Future<void> saveBiometricsEnabled(bool enabled);
}
