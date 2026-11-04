import '../entities/app_entitlement.dart';

/// Onde a marca do app fica no aparelho.
abstract class EntitlementStore {
  /// A marca guardada, ou null se ainda não existe (ou não dá para ler).
  Future<AppEntitlement?> read();

  Future<void> save(AppEntitlement entitlement);
}
