import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/core/storage/providers.dart';
import 'package:mesada/features/family_plan/family_plan.dart';

import '../../support/fakes.dart';
import '../../support/pump_app.dart';

void main() {
  late FakePlanStore store;
  late FakePlanGateway gateway;

  /// Abre o app no modo de verdade (local, sem conta) e vai a
  /// Ajustes › Família.
  Future<void> openPlan(
    WidgetTester tester, {
    FamilyPlan plan = const FamilyPlan.none(),
    bool hasOffer = true,
    bool buys = true,
    bool restores = false,
  }) async {
    store = FakePlanStore(plan: plan);
    gateway = FakePlanGateway(
      hasOffer: hasOffer,
      buys: buys,
      restores: restores,
    );
    await pumpApp(
      tester,
      mode: AppMode.local,
      planStore: store,
      planGateway: gateway,
      clock: () => DateTime(2026, 11, 3),
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

  testWidgets('sem compra, mostra a proposta e o preço da loja', (
    tester,
  ) async {
    await openPlan(tester);

    expect(find.textContaining('veem os mesmos números'), findsOneWidget);
    expect(find.text('Pagamento único, sem mensalidade.'), findsOneWidget);
    expect(
      find.widgetWithText(FilledButton, 'Liberar por R\$ 19,90'),
      findsOneWidget,
    );
  });

  testWidgets('comprar grava o direito com a marca do modelo', (tester) async {
    await openPlan(tester);

    await tester.tap(
      find.widgetWithText(FilledButton, 'Liberar por R\$ 19,90'),
    );
    await tester.pumpAndSettle();

    expect(gateway.calls, ['offer', 'buy']);
    expect(store.plan.kind, PlanKind.lifetime);
    expect(store.plan.productId, 'mesada_familia');
    expect(store.plan.since, DateTime(2026, 11, 3));
    expect(store.plan.modelVersion, 1);
    // A tela passa a mostrar o direito, com a data.
    expect(find.text('Família liberada'), findsOneWidget);
    expect(
      find.text('Pagamento único, desde 3 de novembro de 2026'),
      findsOneWidget,
    );
  });

  testWidgets('compra recusada não grava nada', (tester) async {
    await openPlan(tester, buys: false);

    await tester.tap(
      find.widgetWithText(FilledButton, 'Liberar por R\$ 19,90'),
    );
    await tester.pumpAndSettle();

    expect(store.plan.shares, isFalse);
    expect(find.text('Família liberada'), findsNothing);
  });

  testWidgets('loja sem resposta avisa, e restaurar segue possível', (
    tester,
  ) async {
    await openPlan(tester, hasOffer: false);

    expect(
      find.text('A loja não respondeu agora. Tente de novo mais tarde.'),
      findsOneWidget,
    );
    expect(find.byType(FilledButton), findsNothing);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Restaurar compras'));
    await tester.pumpAndSettle();
    expect(
      find.text('Nenhuma compra encontrada nesta conta da loja.'),
      findsOneWidget,
    );
  });

  testWidgets('restaurar acha a compra e libera', (tester) async {
    await openPlan(tester, restores: true);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Restaurar compras'));
    await tester.pumpAndSettle();

    expect(store.plan.kind, PlanKind.lifetime);
    expect(find.text('Família liberada'), findsOneWidget);
  });

  testWidgets('quem já pagou vê o direito, não a proposta', (tester) async {
    await openPlan(
      tester,
      plan: FamilyPlan.lifetime(since: DateTime(2026, 1, 9)),
    );

    expect(find.text('Família liberada'), findsOneWidget);
    expect(
      find.text('Pagamento único, desde 9 de janeiro de 2026'),
      findsOneWidget,
    );
    expect(find.byType(FilledButton), findsNothing);
  });
}
