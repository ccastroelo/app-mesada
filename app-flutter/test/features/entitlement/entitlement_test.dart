import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/core/storage/device_settings.dart';
import 'package:mesada/core/storage/providers.dart';
import 'package:mesada/features/app_lock/app_lock_providers.dart';
import 'package:mesada/features/entitlement/data/providers.dart';
import 'package:mesada/features/entitlement/data/repositories/entitlement_store_impl.dart';
import 'package:mesada/features/entitlement/data/repositories/legacy_files_detector.dart';
import 'package:mesada/features/entitlement/entitlement.dart';
import 'package:mesada/features/entitlement/entitlement_providers.dart';

import '../../support/fakes.dart';
import '../../support/pump_app.dart';

void main() {
  group('AppEntitlement', () {
    test('o modelo 1 é o teste, a compra única e a assinatura', () {
      expect(AppEntitlement.firstModel, 1);
      expect(AppEntitlement.currentModelVersion, AppEntitlement.firstModel);
      final entitlement = AppEntitlement(since: DateTime(2026, 11, 4));
      expect(entitlement.modelVersion, 1);
      expect(entitlement.origin, EntitlementOrigin.newInstall);
    });

    test('vai e volta pelo JSON sem perder data, modelo nem origem', () {
      final original = AppEntitlement(
        since: DateTime.utc(2026, 11, 4, 9, 30),
        origin: EntitlementOrigin.legacyUpdate,
      );

      final back = AppEntitlement.fromJson(original.toJson())!;

      expect(back.since, DateTime.utc(2026, 11, 4, 9, 30));
      expect(back.modelVersion, 1);
      expect(back.origin, EntitlementOrigin.legacyUpdate);
    });

    test('sem data legível não há marca', () {
      expect(AppEntitlement.fromJson({}), isNull);
      expect(AppEntitlement.fromJson({'modelVersion': 1}), isNull);
      expect(AppEntitlement.fromJson({'since': 'ontem'}), isNull);
      expect(AppEntitlement.fromJson({'since': 123}), isNull);
    });

    test('marca sem número de modelo vale 1, não o modelo de hoje', () {
      // Se um dia o modelo vigente subir, uma marca antiga sem versão não
      // pode ser promovida junto.
      final entitlement = AppEntitlement.fromJson({
        'since': '2026-11-04T00:00:00.000',
      })!;

      expect(entitlement.modelVersion, AppEntitlement.firstModel);
    });

    test('guarda um modelo maior sem rebaixar', () {
      final entitlement = AppEntitlement.fromJson({
        'since': '2026-11-04T00:00:00.000',
        'modelVersion': 7,
      })!;

      expect(entitlement.modelVersion, 7);
    });

    test('origem ausente ou desconhecida vale instalação nova', () {
      for (final origin in [null, 'coisa', 7]) {
        final entitlement = AppEntitlement.fromJson({
          'since': '2026-11-04T00:00:00.000',
          'origin': origin,
        })!;
        expect(entitlement.origin, EntitlementOrigin.newInstall);
      }
    });
  });

  group('maior instante visto (relógio atrasado não devolve dias)', () {
    final since = DateTime(2026, 11, 4, 8);

    test('sem registro, o piso é o primeiro uso', () {
      final entitlement = AppEntitlement(since: since);

      expect(
        entitlement.effectiveNow(since.subtract(const Duration(days: 3))),
        since,
      );
      expect(
        entitlement.effectiveNow(since.add(const Duration(days: 2))),
        since.add(const Duration(days: 2)),
      );
    });

    test('com registro, o relógio atrasado vale o maior instante visto', () {
      final seen = since.add(const Duration(days: 10));
      final entitlement = AppEntitlement(since: since, lastSeen: seen);

      expect(
        entitlement.effectiveNow(since.add(const Duration(days: 1))),
        seen,
      );
      expect(
        entitlement.effectiveNow(since.add(const Duration(days: 12))),
        since.add(const Duration(days: 12)),
      );
    });

    test('só registra quando o relógio andou pelo menos uma hora', () {
      final entitlement = AppEntitlement(since: since);

      expect(
        entitlement.markSeen(since.add(const Duration(minutes: 59))),
        same(entitlement),
      );
      final later = since.add(const Duration(hours: 1));
      final marked = entitlement.markSeen(later);
      expect(marked.lastSeen, later);
      expect(marked.since, since);
      expect(marked.origin, entitlement.origin);
      expect(marked.modelVersion, entitlement.modelVersion);
    });

    test('relógio atrasado não rebaixa o registro', () {
      final seen = since.add(const Duration(days: 10));
      final entitlement = AppEntitlement(since: since, lastSeen: seen);

      expect(
        entitlement.markSeen(since.add(const Duration(days: 1))),
        same(entitlement),
      );
    });

    test('vai e volta pelo JSON; sem registro a chave nem aparece', () {
      final plain = AppEntitlement(since: since);
      expect(plain.toJson().containsKey('lastSeen'), isFalse);

      final seen = DateTime.utc(2026, 11, 20, 9);
      final back = AppEntitlement.fromJson(
        AppEntitlement(since: since, lastSeen: seen).toJson(),
      )!;
      expect(back.lastSeen, seen);
      expect(AppEntitlement.fromJson(plain.toJson())!.lastSeen, isNull);
    });

    test('registro estragado conta como sem registro', () {
      for (final bad in ['ontem', 12, null]) {
        final entitlement = AppEntitlement.fromJson({
          'since': '2026-11-04T08:00:00.000',
          'lastSeen': bad,
        })!;
        expect(entitlement.lastSeen, isNull);
      }
    });

    ProviderContainer open(FakeEntitlementStore store, DateTime now) {
      final container = ProviderContainer(
        overrides: [
          entitlementStoreProvider.overrideWithValue(store),
          legacyAppDetectorProvider.overrideWithValue(FakeLegacyDetector()),
          purchaseStoreProvider.overrideWithValue(FakePurchaseStore()),
          clockProvider.overrideWithValue(() => now),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('depois do teste, atrasar o relógio não volta ao teste', () async {
      // Primeira abertura depois do fim do teste: grava o instante visto.
      final store = FakeEntitlementStore(
        entitlement: AppEntitlement(since: since),
      );
      final afterTrial = since.add(const Duration(days: 20));
      final first = await open(store, afterTrial).read(accessProvider.future);
      expect(first, isA<ReadOnlyAccess>());
      expect(store.entitlement!.lastSeen, afterTrial);

      // A pessoa atrasa o relógio para o meio do teste e abre de novo.
      final back = since.add(const Duration(days: 3));
      final second = await open(store, back).read(accessProvider.future);

      expect(second, isA<ReadOnlyAccess>());
    });

    test('durante o teste, os dias que faltam não aumentam', () async {
      final store = FakeEntitlementStore(
        entitlement: AppEntitlement(since: since),
      );
      await open(
        store,
        since.add(const Duration(days: 10)),
      ).read(accessProvider.future);

      final access = await open(
        store,
        since.add(const Duration(days: 2)),
      ).read(accessProvider.future);

      expect((access as FullAccess).trialDaysLeft, 5);
    });

    test('abrir de novo logo em seguida não grava outra vez', () async {
      final store = FakeEntitlementStore(
        entitlement: AppEntitlement(
          since: since,
          lastSeen: since.add(const Duration(days: 1)),
        ),
      );

      await open(
        store,
        since.add(const Duration(days: 1, minutes: 5)),
      ).read(accessProvider.future);

      expect(store.saves, 0);
    });
  });

  group('EntitlementStoreImpl (device.json numa pasta temporária)', () {
    late Directory base;
    late DeviceSettings settings;
    late EntitlementStoreImpl store;

    setUp(() {
      base = Directory.systemTemp.createTempSync('mesada_entitlement_');
      settings = DeviceSettings(() async => base);
      store = EntitlementStoreImpl(settings);
    });

    tearDown(() => base.deleteSync(recursive: true));

    test('sem marca, lê nulo', () async {
      expect(await store.read(), isNull);
    });

    test('grava e lê de volta', () async {
      await store.save(
        AppEntitlement(
          since: DateTime.utc(2026, 11, 4),
          origin: EntitlementOrigin.legacyUpdate,
        ),
      );

      final back = await store.read();

      expect(back!.since, DateTime.utc(2026, 11, 4));
      expect(back.modelVersion, 1);
      expect(back.origin, EntitlementOrigin.legacyUpdate);
    });

    test('não apaga o PIN nem o modo ao gravar', () async {
      await settings.merge({'pinHash': 'abc', 'mode': 'cloud'});

      await store.save(AppEntitlement(since: DateTime.utc(2026, 11, 4)));

      final json = await settings.read();
      expect(json['pinHash'], 'abc');
      expect(json['mode'], 'cloud');
      expect(json['entitlement'], isNotNull);
    });

    test('valor estragado no arquivo conta como sem marca', () async {
      await settings.merge({'entitlement': 'coisa'});
      expect(await store.read(), isNull);

      await settings.merge({
        'entitlement': {'modelVersion': 1},
      });
      expect(await store.read(), isNull);
    });
  });

  group('LegacyFilesDetector (pasta Documents temporária)', () {
    late Directory documents;
    late LegacyFilesDetector detector;

    setUp(() {
      documents = Directory.systemTemp.createTempSync('mesada_documents_');
      detector = LegacyFilesDetector(() async => documents);
    });

    tearDown(() => documents.deleteSync(recursive: true));

    void touch(Directory directory, String name) => File(
      '${directory.path}${Platform.pathSeparator}$name',
    ).writeAsStringSync('x');

    test('pasta vazia: nunca teve o app antigo', () async {
      expect(await detector.existed(), isFalse);
    });

    test('qualquer um dos três arquivos do app antigo basta', () async {
      for (final name in LegacyFilesDetector.files) {
        final fresh = Directory.systemTemp.createTempSync('mesada_one_');
        addTearDown(() => fresh.deleteSync(recursive: true));
        touch(fresh, name);

        expect(
          await LegacyFilesDetector(() async => fresh).existed(),
          isTrue,
          reason: name,
        );
      }
    });

    test('os arquivos do app novo não contam como app antigo', () async {
      touch(documents, 'mesada.json');
      touch(documents, 'device.json');

      expect(await detector.existed(), isFalse);
    });
  });

  group('entitlementProvider', () {
    ProviderContainer containerWith(
      FakeEntitlementStore store,
      DateTime now, {
      bool legacy = false,
    }) {
      final container = ProviderContainer(
        overrides: [
          entitlementStoreProvider.overrideWithValue(store),
          legacyAppDetectorProvider.overrideWithValue(
            FakeLegacyDetector(found: legacy),
          ),
          clockProvider.overrideWithValue(() => now),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test(
      'no primeiro uso grava a data (início do teste) e o modelo de hoje',
      () async {
        final store = FakeEntitlementStore();
        final container = containerWith(store, DateTime(2026, 11, 4, 8));

        final entitlement = await container.read(entitlementProvider.future);

        expect(entitlement.since, DateTime(2026, 11, 4, 8));
        expect(entitlement.modelVersion, 1);
        expect(entitlement.origin, EntitlementOrigin.newInstall);
        expect(store.saves, 1);
        expect(store.entitlement, same(entitlement));
      },
    );

    test('quem atualiza do app antigo é marcado como tal', () async {
      final store = FakeEntitlementStore();
      final container = containerWith(
        store,
        DateTime(2026, 11, 4),
        legacy: true,
      );

      final entitlement = await container.read(entitlementProvider.future);

      expect(entitlement.origin, EntitlementOrigin.legacyUpdate);
    });

    test('depois disso nunca reescreve: data, modelo e origem ficam', () async {
      final store = FakeEntitlementStore(
        entitlement: AppEntitlement(since: DateTime(2026, 1, 9)),
      );
      // Mesmo que agora apareça rastro do app antigo, a origem não muda.
      final container = containerWith(
        store,
        DateTime(2027, 6, 1),
        legacy: true,
      );

      final entitlement = await container.read(entitlementProvider.future);

      expect(entitlement.since, DateTime(2026, 1, 9));
      expect(entitlement.origin, EntitlementOrigin.newInstall);
      expect(store.saves, 0);
    });
  });

  group('no app inteiro', () {
    testWidgets('abrir o app pela primeira vez grava a marca', (tester) async {
      final store = FakeEntitlementStore();

      await pumpApp(
        tester,
        mode: AppMode.local,
        entitlementStore: store,
        clock: () => DateTime(2026, 11, 4),
      );

      expect(store.entitlement?.since, DateTime(2026, 11, 4));
      expect(store.entitlement?.modelVersion, 1);
    });

    testWidgets('abrir de novo só registra o instante visto', (tester) async {
      final store = FakeEntitlementStore(
        entitlement: AppEntitlement(since: DateTime(2026, 1, 9)),
      );

      await pumpApp(
        tester,
        mode: AppMode.local,
        entitlementStore: store,
        clock: () => DateTime(2026, 11, 4),
      );

      // Data, modelo e origem ficam como estavam; só o maior instante visto
      // anda (e uma vez só).
      expect(store.saves, 1);
      expect(store.entitlement?.since, DateTime(2026, 1, 9));
      expect(store.entitlement?.modelVersion, 1);
      expect(store.entitlement?.origin, EntitlementOrigin.newInstall);
      expect(store.entitlement?.lastSeen, DateTime(2026, 11, 4));
    });
  });
}
