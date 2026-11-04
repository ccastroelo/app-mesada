import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/state/action_controller.dart';
import '../../../app_lock/app_lock_providers.dart';
import '../../data/providers.dart';
import '../../domain/entities/family_plan.dart';
import '../../domain/repositories/plan_gateway.dart';

/// O direito guardado neste aparelho (ADR-0020).
final familyPlanProvider = FutureProvider<FamilyPlan>(
  (ref) => ref.watch(planStoreProvider).read(),
);

/// O que a loja oferece; null quando a loja não respondeu ou não tem o
/// produto (aparelho sem loja, produto ainda não publicado).
final planOfferProvider = FutureProvider<PlanOffer?>(
  (ref) => ref.watch(planGatewayProvider).offer(),
);

/// Comprar e restaurar. Usa o `ActionController` como as outras ações de
/// tela: carregando no botão e falha em texto.
class FamilyPlanActions extends ActionController {
  /// true quando a loja confirmou e o direito passou a valer.
  Future<bool> buy() => _grantIf(() => ref.read(planGatewayProvider).buy());

  Future<bool> restore() =>
      _grantIf(() => ref.read(planGatewayProvider).restore());

  Future<bool> _grantIf(Future<bool> Function() storeAction) async {
    state = const ActionState(loading: true);
    final ok = await storeAction();
    if (ok) {
      // A loja é a fonte de verdade; aqui só se guarda a cópia local, com a
      // marca de qual modelo de cobrança valia na hora (ADR-0020).
      await ref
          .read(planStoreProvider)
          .save(FamilyPlan.lifetime(since: ref.read(clockProvider)()));
      if (ref.mounted) ref.invalidate(familyPlanProvider);
    }
    if (ref.mounted) state = const ActionState();
    return ok;
  }
}

final familyPlanActionsProvider =
    NotifierProvider.autoDispose<FamilyPlanActions, ActionState>(
      FamilyPlanActions.new,
    );
