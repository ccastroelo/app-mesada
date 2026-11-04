import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/core/storage/providers.dart';

import '../../../support/pump_app.dart';

void main() {
  /// Abre o app no modo de verdade (local, sem conta) e vai a
  /// Ajustes › Família.
  Future<void> openSharing(WidgetTester tester) async {
    await pumpApp(tester, mode: AppMode.local);
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

  testWidgets('explica que os dois veem os mesmos números e que cada um tem o '
      'app', (tester) async {
    await openSharing(tester);

    expect(find.textContaining('veem os mesmos números'), findsOneWidget);
    expect(
      find.textContaining('instala o Mesada no aparelho dele'),
      findsOneWidget,
    );
    expect(find.textContaining('sobem para a nuvem'), findsOneWidget);
  });

  testWidgets('o próximo passo é entrar, sem compra nem restauração', (
    tester,
  ) async {
    await openSharing(tester);

    // Que o toque grave o modo no aparelho se prova em
    // `core/storage/app_mode_state_test.dart`: num teste de widget, I/O
    // começado fora de `runAsync` não completa.
    expect(
      find.widgetWithText(FilledButton, 'Entrar para compartilhar'),
      findsOneWidget,
    );
    expect(find.textContaining('Liberar por'), findsNothing);
    expect(find.text('Restaurar compras'), findsNothing);
    expect(find.textContaining('Pagamento único'), findsNothing);
    expect(find.textContaining('assinatura'), findsNothing);
  });
}
