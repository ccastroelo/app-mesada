import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/storage/providers.dart';
import '../domain/repositories/entitlement_store.dart';
import '../domain/repositories/legacy_app_detector.dart';
import 'repositories/entitlement_store_impl.dart';
import 'repositories/legacy_files_detector.dart';

/// Raiz de composição da feature; os testes trocam por falsos.
final entitlementStoreProvider = Provider<EntitlementStore>(
  (ref) => EntitlementStoreImpl(ref.watch(deviceSettingsProvider)),
);

final legacyAppDetectorProvider = Provider<LegacyAppDetector>(
  (ref) => LegacyFilesDetector(getApplicationDocumentsDirectory),
);
