import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

/// De onde os dados vêm **neste aparelho**, lido do `device.json` (ADR-0014).
/// O padrão é local: quem nunca liberou a Família nunca viu nuvem.
final savedModeProvider = FutureProvider<AppMode>((ref) async {
  final json = await ref.watch(deviceSettingsProvider).read();
  return json['mode'] == AppMode.cloud.name ? AppMode.cloud : AppMode.local;
});

/// Troca o modo e refaz tudo que depende dele (repositórios e portão).
///
/// A virada para a nuvem é em mão única e acontece **uma vez**, quando a
/// família é criada com o conteúdo deste aparelho; voltar para local é a
/// saída de emergência de quem desistiu no meio.
Future<void> setAppMode(WidgetRef ref, AppMode mode) async {
  await ref.read(deviceSettingsProvider).merge({'mode': mode.name});
  ref.invalidate(savedModeProvider);
}
