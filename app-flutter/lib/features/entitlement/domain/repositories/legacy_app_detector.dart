/// Descobre se este aparelho já teve o app antigo (iOS 1.2, em Objective-C).
abstract class LegacyAppDetector {
  /// true se há sinais de uso do app antigo neste aparelho.
  Future<bool> existed();
}
