import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/core/storage/providers.dart';

import '../../../support/pump_app.dart';

/// O caminho padrão do app (ADR-0014/0015): sem conta, sem Firebase, com os
/// repositórios de verdade sobre um arquivo numa pasta temporária.
void main() {
  Finder inAppBar(String text) =>
      find.descendant(of: find.byType(AppBar), matching: find.text(text));
  Finder inNavBar(String text) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(text),
  );

  Future<void> openTab(WidgetTester tester, String label) async {
    await tester.tap(inNavBar(label));
    await tester.pumpAndSettle();
  }

  testWidgets('primeira abertura cai em Filhos, sem pedir conta', (
    tester,
  ) async {
    await pumpApp(tester, mode: AppMode.local);

    expect(inAppBar('Filhos'), findsOneWidget);
    expect(find.text('Boas-vindas'), findsNothing);
    expect(find.text('Adicione o primeiro filho para começar'), findsOneWidget);
  });

  testWidgets('Ajustes mostra a família do aparelho, sem conta', (
    tester,
  ) async {
    await pumpApp(tester, mode: AppMode.local);

    await openTab(tester, 'Ajustes');

    expect(find.text('Minha família'), findsOneWidget);
    expect(find.text('Só neste aparelho'), findsOneWidget);
    // Convidar e sair da conta só existem com assinatura (ADR-0015).
    expect(find.text('Convidar outro responsável'), findsNothing);
    expect(find.text('Sair'), findsNothing);
  });

  testWidgets('usar sugestões passa pelo repositório local de verdade', (
    tester,
  ) async {
    await pumpApp(tester, mode: AppMode.local);

    await openTab(tester, 'Regras');
    expect(find.text('Nenhuma regra ainda'), findsOneWidget);

    await tester.tap(find.text('Usar sugestões'));
    await tester.pumpAndSettle();

    // A lista aparece porque a mudança vale em memória antes do disco. Que o
    // arquivo é escrito fica provado em `core/storage/local_store_test.dart`:
    // num teste de widget, I/O começado fora de `runAsync` não completa.
    expect(find.text('Arrumar a cama'), findsOneWidget);
    expect(find.text('Deixar a luz acesa'), findsOneWidget);
  });
}
