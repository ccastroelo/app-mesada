import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/storage/providers.dart';
import '../domain/repositories/entitlement_store.dart';
import '../domain/repositories/legacy_app_detector.dart';
import '../domain/repositories/purchase_store.dart';
import '../domain/repositories/store_gateway.dart';
import 'repositories/entitlement_store_impl.dart';
import 'repositories/legacy_files_detector.dart';
import 'repositories/purchase_store_impl.dart';
import 'repositories/revenuecat_store_gateway.dart';

/// Raiz de composição da feature; os testes trocam por falsos.
final entitlementStoreProvider = Provider<EntitlementStore>(
  (ref) => EntitlementStoreImpl(ref.watch(deviceSettingsProvider)),
);

final legacyAppDetectorProvider = Provider<LegacyAppDetector>(
  (ref) => LegacyFilesDetector(getApplicationDocumentsDirectory),
);

final purchaseStoreProvider = Provider<PurchaseStore>(
  (ref) => PurchaseStoreImpl(ref.watch(deviceSettingsProvider)),
);

/// A loja de verdade. Nenhum teste fala com ela.
final storeGatewayProvider = Provider<StoreGateway>(
  (ref) => RevenueCatStoreGateway(),
);
