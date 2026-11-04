import '../entities/family_plan.dart';

/// Cópia local do direito, para o app saber o que vale sem depender da loja
/// nem de rede a cada abertura (ADR-0020).
abstract class PlanStore {
  Future<FamilyPlan> read();

  Future<void> save(FamilyPlan plan);
}
