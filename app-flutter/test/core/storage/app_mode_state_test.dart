import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/core/storage/app_mode_state.dart';
import 'package:mesada/core/storage/device_settings.dart';
import 'package:mesada/core/storage/providers.dart';

void main() {
  late Directory base;
  late DeviceSettings settings;
  late ProviderContainer container;

  setUp(() {
    base = Directory.systemTemp.createTempSync('mesada_mode_');
    settings = DeviceSettings(() async => base);
    container = ProviderContainer(
      overrides: [deviceSettingsProvider.overrideWithValue(settings)],
    );
    addTearDown(container.dispose);
  });

  tearDown(() => base.deleteSync(recursive: true));

  test('aparelho novo é local: quem nunca liberou nunca viu nuvem', () async {
    expect(await container.read(savedModeProvider.future), AppMode.local);
  });

  test('a virada para a nuvem fica gravada no aparelho', () async {
    // É o que `setAppMode` faz: grava e manda reler.
    await settings.merge({'mode': 'cloud'});
    container.invalidate(savedModeProvider);

    expect(await container.read(savedModeProvider.future), AppMode.cloud);
    // E o modo em uso acompanha.
    expect(container.read(appModeProvider), AppMode.cloud);
  });

  test('voltar para local é só gravar de novo', () async {
    await settings.merge({'mode': 'cloud'});
    container.invalidate(savedModeProvider);
    await container.read(savedModeProvider.future);

    await settings.merge({'mode': 'local'});
    container.invalidate(savedModeProvider);

    expect(await container.read(savedModeProvider.future), AppMode.local);
  });

  test('valor estranho no arquivo conta como local', () async {
    await settings.merge({'mode': 'coisa'});

    expect(await container.read(savedModeProvider.future), AppMode.local);
  });

  test('a troca de modo não apaga o PIN nem o plano', () async {
    await settings.merge({
      'pinHash': 'abc',
      'familyPlan': {'kind': 'lifetime'},
    });

    await settings.merge({'mode': 'cloud'});

    final json = await settings.read();
    expect(json['pinHash'], 'abc');
    expect(json['familyPlan'], isNotNull);
    expect(json['mode'], 'cloud');
  });
}
