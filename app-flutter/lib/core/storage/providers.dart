import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'device_settings.dart';
import 'local_store.dart';

/// De onde vêm os dados. Uma fonte de verdade por vez, nunca as duas
/// (ADR-0014): no grátis é o arquivo do aparelho; a nuvem entra com a
/// assinatura Família (M4.5), e é só aí que o Firebase é inicializado.
enum AppMode { local, cloud }

final appModeProvider = Provider<AppMode>((ref) => AppMode.local);

final localStoreProvider = Provider<LocalStore>(
  (ref) => LocalStore(getApplicationDocumentsDirectory),
);

/// Ajustes do aparelho (PIN, biometria), num arquivo só e sempre local.
final deviceSettingsProvider = Provider<DeviceSettings>(
  (ref) => DeviceSettings(getApplicationDocumentsDirectory),
);
