import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/core/storage/providers.dart';
import 'package:mesada/features/entitlement/entitlement.dart';

import '../../../support/fakes.dart';
import '../../../support/pump_app.dart';

void main() {
  /// Abre o app no modo de verdade (local, sem conta) e vai a
  /// Ajustes › Família.
  Future<void> openSharing(
    WidgetTester tester, {
    FakeStoreGateway? gateway,
    FakePurchaseStore? purchases,
  }) async {
    await pumpApp(
      tester,
      mode: AppMode.local,
      storeGateway: gateway,
      purchaseStore: purchases,
    );
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Ajustes'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(ListTile, 'Compartilhar com o outro responsável'),
    );
    await tester.pumpAndSettle();
  }

  FakePurchaseStore subscribed() => FakePurchaseStore(
    records: [
      PurchaseRecord(product: StoreProduct.app, since: DateTime(2026, 1, 1)),
      PurchaseRecord(
        product: StoreProduct.sharing,
        since: DateTime(2026, 1, 2),
      ),
    ],
  );

  final enter = find.widgetWithText(FilledButton, 'Entrar para compartilhar');

  testWidgets('explica que os dois veem os mesmos números e que cada um tem o '
      'app', (tester) async {
    await openSharing(tester);

    expect(find.textContaining('veem os mesmos números'), findsOneWidget);
    expect(
      find.textContaining('instala o Mesada no aparelho dele'),
      findsOneWidget,
    );
  });

  testWidgets('sem a assinatura, oferece assinar e restaurar, e não deixa '
      'entrar', (tester) async {
    await openSharing(tester);

    expect(find.textContaining('assinatura por família'), findsOneWidget);
    expect(
      find.widgetWithText(FilledButton, r'Assinar por R$ 9,90'),
      findsOneWidget,
    );
    expect(find.text('Restaurar compras'), findsOneWidget);
    expect(enter, findsNothing);
  });

  testWidgets('assinar pela loja libera o próximo passo, que é entrar', (
    tester,
  ) async {
    final gateway = FakeStoreGateway();
    final purchases = FakePurchaseStore.ownsApp();
    await openSharing(tester, gateway: gateway, purchases: purchases);

    await tester.tap(find.widgetWithText(FilledButton, r'Assinar por R$ 9,90'));
    await tester.pumpAndSettle();

    expect(gateway.bought, [StoreProduct.sharing]);
    expect(purchases.records, contains(StoreProduct.sharing));
    expect(enter, findsOneWidget);
    expect(find.textContaining('sobem para a nuvem'), findsOneWidget);
    expect(find.textContaining('Assinar por'), findsNothing);
  });

  testWidgets('se a loja não confirmar, nada é guardado e a oferta continua', (
    tester,
  ) async {
    final gateway = FakeStoreGateway(buyResult: false);
    final purchases = FakePurchaseStore.ownsApp();
    await openSharing(tester, gateway: gateway, purchases: purchases);

    await tester.tap(find.widgetWithText(FilledButton, r'Assinar por R$ 9,90'));
    await tester.pumpAndSettle();

    expect(purchases.records.keys, [StoreProduct.app]);
    expect(enter, findsNothing);
    expect(find.textContaining('Assinar por'), findsOneWidget);
  });

  testWidgets('restaurar encontra a assinatura da conta da loja', (
    tester,
  ) async {
    final gateway = FakeStoreGateway(restorable: {StoreProduct.sharing});
    await openSharing(tester, gateway: gateway);

    await tester.tap(find.text('Restaurar compras'));
    await tester.pumpAndSettle();

    expect(gateway.restores, 1);
    expect(enter, findsOneWidget);
  });

  testWidgets('restaurar sem nada na conta avisa e não libera', (tester) async {
    final gateway = FakeStoreGateway();
    await openSharing(tester, gateway: gateway);

    await tester.tap(find.text('Restaurar compras'));
    await tester.pumpAndSettle();

    expect(
      find.text('Nenhuma compra encontrada nesta conta da loja.'),
      findsOneWidget,
    );
    expect(enter, findsNothing);
  });

  testWidgets('loja sem resposta: diz isso e mantém a restauração', (
    tester,
  ) async {
    await openSharing(tester, gateway: FakeStoreGateway(prices: const {}));

    expect(
      find.text('A loja não respondeu agora. Tente de novo mais tarde.'),
      findsOneWidget,
    );
    expect(find.text('Restaurar compras'), findsOneWidget);
    expect(enter, findsNothing);
  });

  testWidgets('quem já assinou vai direto ao próximo passo', (tester) async {
    await openSharing(tester, purchases: subscribed());

    expect(enter, findsOneWidget);
    expect(find.text('Restaurar compras'), findsNothing);
  });
}
