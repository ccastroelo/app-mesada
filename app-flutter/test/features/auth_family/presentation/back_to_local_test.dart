import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/core/error/failure.dart';
import 'package:mesada/core/storage/device_settings.dart';
import 'package:mesada/core/storage/local_store.dart';
import 'package:mesada/core/storage/providers.dart';
import 'package:mesada/features/auth_family/auth_family.dart';
import 'package:mesada/features/auth_family/data/providers.dart';
import 'package:mesada/features/auth_family/domain/entities/family_snapshot.dart';
import 'package:mesada/features/auth_family/presentation/state/controllers.dart';

import '../../../support/fakes.dart';
import '../../../support/pump_app.dart';

void main() {
  group('BackToLocalController (arquivo e ajustes numa pasta temporária)', () {
    late Directory base;
    late LocalStore store;
    late DeviceSettings settings;
    late FakeFamilyRepository family;
    late ProviderContainer container;

    setUp(() async {
      base = Directory.systemTemp.createTempSync('mesada_back_to_local_');
      store = LocalStore(() async => base);
      settings = DeviceSettings(() async => base);
      family = FakeFamilyRepository(
        family: const Family(id: 'f1', name: 'Família Castro'),
      );
      family.snapshot = const FamilySnapshot(
        name: 'Família Castro',
        children: [
          {'id': 'c1', 'name': 'Ana', 'allowanceCents': 10000},
        ],
        rules: [
          {'id': 'r1', 'description': 'Arrumar a cama', 'valueCents': 50},
        ],
        entries: [
          {'childId': 'c1', 'ruleId': 'r1', 'quantity': 2},
        ],
      );
      await settings.merge({'mode': 'cloud', 'pinHash': 'abc'});
      container = ProviderContainer(
        overrides: [
          appModeProvider.overrideWithValue(AppMode.cloud),
          authRepositoryProvider.overrideWithValue(
            FakeAuthRepository(user: testUser),
          ),
          familyRepositoryProvider.overrideWithValue(family),
          localStoreProvider.overrideWithValue(store),
          deviceSettingsProvider.overrideWithValue(settings),
        ],
      );
      // O portão e a ação precisam de alguém ouvindo (são autoDispose/streams).
      container.listen(gateProvider, (_, _) {});
      container.listen(backToLocalControllerProvider, (_, _) {});
      for (
        var i = 0;
        i < 50 && container.read(gateProvider) is! GateReady;
        i++
      ) {
        await Future<void>.delayed(Duration.zero);
      }
      expect(container.read(gateProvider), isA<GateReady>());
    });

    tearDown(() {
      container.dispose();
      base.deleteSync(recursive: true);
    });

    test('baixa o retrato para o arquivo local e troca o modo', () async {
      final done = await container
          .read(backToLocalControllerProvider.notifier)
          .leave();

      expect(done, isTrue);
      expect(family.downloads, ['f1']);
      final document = await store.watch().first;
      expect(document.familyId, 'local');
      expect(document.family['name'], 'Família Castro');
      expect(document.children.single['id'], 'c1');
      expect(document.rules.single['id'], 'r1');
      expect(document.entries.single['quantity'], 2);
      final json = await settings.read();
      expect(json['mode'], 'local');
      // Os outros ajustes do aparelho ficam como estavam.
      expect(json['pinHash'], 'abc');
    });

    test('o retrato substitui o que havia no arquivo local', () async {
      await store.update(
        (document) => document.copyWith(
          children: [
            {'id': 'velho', 'name': 'Antigo'},
          ],
        ),
      );

      await container.read(backToLocalControllerProvider.notifier).leave();

      final document = await store.watch().first;
      expect(document.children.map((child) => child['id']), ['c1']);
    });

    test('se baixar falhar, nada muda: segue na nuvem', () async {
      family.snapshotFailure = const NoConnection();

      final done = await container
          .read(backToLocalControllerProvider.notifier)
          .leave();

      expect(done, isFalse);
      expect(
        container.read(backToLocalControllerProvider).failure,
        isA<NoConnection>(),
      );
      final document = await store.watch().first;
      expect(document.children, isEmpty);
      expect((await settings.read())['mode'], 'cloud');
    });
  });

  group('Ajustes', () {
    Future<void> openSettings(WidgetTester tester, AppMode mode) async {
      await pumpApp(
        tester,
        mode: mode,
        auth: FakeAuthRepository(user: testUser),
        family: FakeFamilyRepository(
          family: const Family(id: 'f1', name: 'Família Castro'),
        ),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Ajustes'),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('na nuvem, oferece voltar a usar só neste aparelho', (
      tester,
    ) async {
      await openSettings(tester, AppMode.cloud);

      await tester.tap(find.text('Voltar a usar só neste aparelho'));
      await tester.pumpAndSettle();

      expect(find.text('Usar só neste aparelho?'), findsOneWidget);
      expect(find.textContaining('não é apagado'), findsOneWidget);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.text('Usar só neste aparelho?'), findsNothing);
    });

    testWidgets('no modo local não há o que voltar', (tester) async {
      await openSettings(tester, AppMode.local);

      expect(find.text('Voltar a usar só neste aparelho'), findsNothing);
    });
  });
}
