/// O PIN guardado: sal e hash (nunca o PIN em si).
class PinCredential {
  const PinCredential({required this.salt, required this.hash});

  final String salt;
  final String hash;
}

/// Onde moram os ajustes do bloqueio: o PIN e o liga/desliga da biometria.
/// São **do aparelho**, não da família (design.md §4.11): ficam num arquivo
/// separado do `mesada.json` para nunca subir junto com os dados na
/// assinatura (ADR-0014/0017).
abstract class PinStore {
  /// A credencial guardada, ou null quando o PIN está desativado.
  Future<PinCredential?> read();

  Future<void> save(PinCredential credential);

  /// Apaga o PIN **e** desliga a biometria: sem PIN não há reserva.
  Future<void> clear();

  Future<bool> readBiometricsEnabled();

  Future<void> saveBiometricsEnabled(bool enabled);
}
