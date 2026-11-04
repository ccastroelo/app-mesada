import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../core/storage/providers.dart';
import '../domain/repositories/plan_gateway.dart';
import '../domain/repositories/plan_store.dart';
import 'repositories/in_app_purchase_plan_gateway.dart';
import 'repositories/plan_store_impl.dart';

/// Raiz de composição da feature; os testes trocam por versões falsas.
final planStoreProvider = Provider<PlanStore>(
  (ref) => PlanStoreImpl(ref.watch(deviceSettingsProvider)),
);

final planGatewayProvider = Provider<PlanGateway>(
  (ref) => InAppPurchasePlanGateway(InAppPurchase.instance),
);
