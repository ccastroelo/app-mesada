import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/app.dart';
import 'package:mesada/core/error/failure.dart';
import 'package:mesada/core/storage/device_settings.dart';
import 'package:mesada/features/auth_family/domain/entities/family.dart';
import 'package:mesada/features/children/children.dart';
import 'package:mesada/features/entitlement/data/repositories/purchase_store_impl.dart';
import 'package:mesada/features/entitlement/entitlement.dart';
import 'package:mesada/features/rules/rules.dart';
import 'package:mesada/features/rules/presentation/state/rules_state.dart';

import '../../support/fakes.dart';
import '../../support/pump_app.dart';

void main() {
  group('StoreProduct e PurchaseRecord', () {
    test('os ids são os cadastrados nas lojas', () {
      expect(StoreProduct.app.id, 'mesada_app');
      expect(StoreProduct.sharing.id, 'mesada_compartilhar');
      expect(StoreProduct.app.isSubscription, isFalse);
      expect(StoreProduct.sharing.isSubscription, isTrue);
      expect(StoreProduct.byId('mesada_app'), StoreProduct.app);
      expect(StoreProduct.byId('outra_coisa'), isNull);
    });

    test('vai e volta pelo JSON', () {
      final record = PurchaseRecord(
        product: StoreProduct.sharing,
        since: DateTime.utc(2026, 11, 4, 10),
      );

      final back = PurchaseRecord.fromJson(record.toJson())!;

      expect(back.product, StoreProduct.sharing);
      expect(back.since, DateTime.utc(2026, 11, 4, 10));
    });

    test('produto desconhecido ou data ilegível não é compra', () {
      expect(
        PurchaseRecord.fromJson({'product': 'x', 'since': '2026-11-04'}),
        isNull,
      );
      expect(
        PurchaseRecord.fromJson({'product': 'mesada_app', 'since': 'ontem'}),
        isNull,
      );
      expect(PurchaseRecord.fromJson({'product': 'mesada_app'}), isNull);
    });
  });

  group('PurchaseStoreImpl (device.json numa pasta temporária)', () {
    late Directory base;
    late DeviceSettings settings;
    late PurchaseStoreImpl store;

    setUp(() {
      base = Directory.systemTemp.createTempSync('mesada_purchases_');
      settings = DeviceSettings(() async => base);
      store = PurchaseStoreImpl(settings);
    });

    tearDown(() => base.deleteSync(recursive: true));

    test('sem compras, lê vazio', () async {
      expect(await store.read(), isEmpty);
    });

    test('guarda os dois produtos sem um apagar o outro', () async {
      await store.save(
        PurchaseRecord(product: StoreProduct.app, since: DateTime.utc(2026)),
      );
      await store.save(
        PurchaseRecord(
          product: StoreProduct.sharing,
          since: DateTime.utc(2026, 2),
        ),
      );

      final back = await store.read();

      expect(back.keys, unorderedEquals(StoreProduct.values));
      expect(back[StoreProduct.sharing]!.since, DateTime.utc(2026, 2));
    });

    test('não apaga o PIN, o modo nem a marca do app', () async {
      await settings.merge({
        'pinHash': 'abc',
        'mode': 'cloud',
        'entitlement': {'since': '2026-11-04T00:00:00.000'},
      });

      await store.save(
        PurchaseRecord(product: StoreProduct.app, since: DateTime.utc(2026)),
      );

      final json = await settings.read();
      expect(json['pinHash'], 'abc');
      expect(json['mode'], 'cloud');
      expect(json['entitlement'], isNotNull);
      expect(json['purchases'], isNotNull);
    });

    test('registro estragado no arquivo é ignorado', () async {
      await settings.merge({
        'purchases': {
          'mesada_app': 'coisa',
          'x': {'product': 'x', 'since': '2026-01-01'},
        },
      });

      expect(await store.read(), isEmpty);
    });
  });

  group('acesso pelas telas (ADR-0021)', () {
    final started = DateTime(2026, 11, 4);
    const maria = Child(id: 'c1', name: 'Maria', allowanceCents: 10000);
    const bed = Rule(id: 'r1', description: 'Arrumar a cama', valueCents: 50);

    DateTime daysAfter(int days) => started.add(Duration(days: days));

    /// Abre o app em [now], com a marca de primeiro uso em [started] e sem a
    /// compra do app, a menos que [owns] ou que [purchases] diga outra coisa.
    Future<void> open(
      WidgetTester tester, {
      required DateTime now,
      bool owns = false,
      FakeStoreGateway? gateway,
      FakePurchaseStore? purchases,
      List<Rule> rules = const [],
    }) => pumpApp(
      tester,
      auth: FakeAuthRepository(user: testUser),
      family: FakeFamilyRepository(
        family: const Family(id: 'f1', name: 'Família Castro'),
      ),
      children: FakeChildrenRepository(children: const [maria]),
      rules: FakeRulesRepository(rules: rules),
      clock: () => now,
      entitlementStore: FakeEntitlementStore(
        entitlement: AppEntitlement(since: started),
      ),
      storeGateway: gateway,
      purchaseStore:
          purchases ??
          (owns ? FakePurchaseStore.ownsApp() : FakePurchaseStore()),
    );

    Finder tab(String label) => find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text(label),
    );

    final newChild = find.text('Adicionar filho');
    final buyShortcut = find.widgetWithText(TextButton, 'Comprar');
    const buyPrice = r'Comprar por R$ 19,90';

    testWidgets('dentro do teste: mostra os dias e libera tudo', (
      tester,
    ) async {
      await open(tester, now: daysAfter(6));

      expect(find.text('Teste grátis: faltam 9 dias'), findsOneWidget);
      expect(newChild, findsOneWidget);
    });

    testWidgets('no último dia, o texto vai para o singular', (tester) async {
      await open(tester, now: daysAfter(14));

      expect(find.text('Teste grátis: falta 1 dia'), findsOneWidget);
    });

    testWidgets('quem comprou o app não vê faixa nenhuma', (tester) async {
      await open(tester, now: daysAfter(400), owns: true);

      expect(find.textContaining('Teste grátis'), findsNothing);
      expect(find.textContaining('O teste acabou'), findsNothing);
      expect(newChild, findsOneWidget);
    });

    testWidgets('teste acabado sem compra: só leitura, mas tudo à vista', (
      tester,
    ) async {
      await open(tester, now: daysAfter(20));

      expect(find.textContaining('O teste acabou'), findsOneWidget);
      expect(find.text('Maria'), findsOneWidget);
      expect(newChild, findsNothing);
    });

    testWidgets('só leitura na aba Regras: sem botão de nova regra', (
      tester,
    ) async {
      await open(tester, now: daysAfter(20));

      await tester.tap(tab('Regras'));
      await tester.pumpAndSettle();

      expect(find.textContaining('O teste acabou'), findsOneWidget);
      expect(find.text('Nova regra'), findsNothing);
    });

    testWidgets('só leitura: a escrita é recusada mesmo sem passar pela tela', (
      tester,
    ) async {
      await open(tester, now: daysAfter(20));
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MesadaApp)),
      );
      // A ação é autoDispose: alguém precisa estar ouvindo para o estado ficar.
      final subscription = container.listen(rulesActionsProvider, (_, _) {});
      addTearDown(subscription.close);

      final added = await container
          .read(rulesActionsProvider.notifier)
          .add(description: 'Arrumar a cama', valueCents: 50);

      expect(added, isFalse);
      expect(container.read(rulesActionsProvider).failure, isA<ReadOnly>());
    });

    testWidgets('na tela do filho, os botões − e + ficam desligados', (
      tester,
    ) async {
      await open(tester, now: daysAfter(20), rules: const [bed]);
      await tester.tap(find.text('Maria'));
      await tester.pumpAndSettle();

      final increase = find.ancestor(
        of: find.byTooltip('Aumentar Arrumar a cama, quantidade 0'),
        matching: find.byType(IconButton),
      );
      expect(increase, findsOneWidget);
      expect(tester.widget<IconButton>(increase).onPressed, isNull);
    });

    testWidgets('na tela do filho, com acesso, o + liga', (tester) async {
      await open(tester, now: daysAfter(20), owns: true, rules: const [bed]);
      await tester.tap(find.text('Maria'));
      await tester.pumpAndSettle();

      final increase = find.ancestor(
        of: find.byTooltip('Aumentar Arrumar a cama, quantidade 0'),
        matching: find.byType(IconButton),
      );
      expect(tester.widget<IconButton>(increase).onPressed, isNotNull);
    });

    testWidgets('a faixa leva à compra, que libera tudo e volta', (
      tester,
    ) async {
      final gateway = FakeStoreGateway();
      final purchases = FakePurchaseStore();
      await open(
        tester,
        now: daysAfter(20),
        gateway: gateway,
        purchases: purchases,
      );

      await tester.tap(buyShortcut);
      await tester.pumpAndSettle();
      expect(find.text('Comprar o Mesada'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, buyPrice));
      await tester.pumpAndSettle();

      expect(gateway.bought, [StoreProduct.app]);
      expect(purchases.records, contains(StoreProduct.app));
      // Voltou à lista, agora liberada.
      expect(find.textContaining('O teste acabou'), findsNothing);
      expect(newChild, findsOneWidget);
    });

    testWidgets('se a loja não confirmar, segue em só leitura', (tester) async {
      final purchases = FakePurchaseStore();
      await open(
        tester,
        now: daysAfter(20),
        gateway: FakeStoreGateway(buyResult: false),
        purchases: purchases,
      );

      await tester.tap(buyShortcut);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, buyPrice));
      await tester.pumpAndSettle();

      expect(purchases.records, isEmpty);
      expect(find.text('Comprar o Mesada'), findsOneWidget);
    });

    testWidgets('restaurar traz de volta quem já tinha comprado', (
      tester,
    ) async {
      final gateway = FakeStoreGateway(restorable: {StoreProduct.app});
      await open(tester, now: daysAfter(20), gateway: gateway);

      await tester.tap(buyShortcut);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Restaurar compras'));
      await tester.pumpAndSettle();

      expect(gateway.restores, 1);
      expect(find.textContaining('O teste acabou'), findsNothing);
    });

    testWidgets('restaurar sem nada avisa e fica na tela de compra', (
      tester,
    ) async {
      await open(tester, now: daysAfter(20));

      await tester.tap(buyShortcut);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Restaurar compras'));
      await tester.pumpAndSettle();

      expect(
        find.text('Nenhuma compra encontrada nesta conta da loja.'),
        findsOneWidget,
      );
      expect(find.text('Comprar o Mesada'), findsOneWidget);
    });

    testWidgets('loja sem resposta: avisa e mantém a restauração', (
      tester,
    ) async {
      await open(
        tester,
        now: daysAfter(20),
        gateway: FakeStoreGateway(prices: const {}),
      );

      await tester.tap(buyShortcut);
      await tester.pumpAndSettle();

      expect(
        find.text('A loja não respondeu agora. Tente de novo mais tarde.'),
        findsOneWidget,
      );
      expect(find.text('Restaurar compras'), findsOneWidget);
    });

    testWidgets('Ajustes mostra o atalho de compra enquanto falta comprar', (
      tester,
    ) async {
      await open(tester, now: daysAfter(6));
      await tester.tap(tab('Ajustes'));
      await tester.pumpAndSettle();

      expect(find.text('Comprar o app'), findsOneWidget);
    });

    testWidgets('Ajustes não mostra o atalho a quem comprou', (tester) async {
      await open(tester, now: daysAfter(6), owns: true);
      await tester.tap(tab('Ajustes'));
      await tester.pumpAndSettle();

      expect(find.text('Comprar o app'), findsNothing);
    });

    testWidgets('a faixa de só leitura cabe a 2,0× em tela pequena', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await open(tester, now: daysAfter(20));

      expect(tester.takeException(), isNull);
      expect(find.textContaining('O teste acabou'), findsOneWidget);
    });
  });
}
