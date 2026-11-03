/// O PIN guardado: sal e hash (nunca o PIN em si).
class PinCredential {
  const PinCredential({required this.salt, required this.hash});

  final String salt;
  final String hash;
}

/// Onde o PIN mora. É **do aparelho**, não da família (design.md §4.11): fica
/// num arquivo separado do `mesada.json` para nunca subir junto com os dados
/// na assinatura (ADR-0014/0015).
abstract class PinStore {
  /// A credencial guardada, ou null quando o PIN está desativado.
  Future<PinCredential?> read();

  Future<void> save(PinCredential credential);

  Future<void> clear();
}
