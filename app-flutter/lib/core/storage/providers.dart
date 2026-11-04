import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'app_mode_state.dart';
import 'device_settings.dart';
import 'local_store.dart';

/// De onde vêm os dados. Uma fonte de verdade por vez, nunca as duas
/// (ADR-0014): no grátis é o arquivo do aparelho; a nuvem entra com a
/// assinatura Família (M4.5), e é só aí que o Firebase é inicializado.
enum AppMode { local, cloud }

/// O modo em uso. Vem do `device.json` (`savedModeProvider`); enquanto o
/// arquivo não respondeu vale `local`, e o portão segura o conteúdo até lá.
final appModeProvider = Provider<AppMode>(
  (ref) => ref.watch(savedModeProvider).value ?? AppMode.local,
);

final localStoreProvider = Provider<LocalStore>(
  (ref) => LocalStore(getApplicationDocumentsDirectory),
);

/// Ajustes do aparelho (PIN, biometria), num arquivo só e sempre local.
final deviceSettingsProvider = Provider<DeviceSettings>(
  (ref) => DeviceSettings(getApplicationDocumentsDirectory),
);
