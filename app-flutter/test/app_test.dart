import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/app.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester, Locale locale) async {
    tester.platformDispatcher.localesTestValue = [locale];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await tester.pumpWidget(const ProviderScope(child: MesadaApp()));
    await tester.pumpAndSettle();
  }

  testWidgets('abre em Filhos e navega pelos 3 destinos', (tester) async {
    await pumpApp(tester, const Locale('pt', 'BR'));

    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Filhos')),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Regras'),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Regras')),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Ajustes'),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Ajustes')),
      findsOneWidget,
    );
  });

  testWidgets('textos seguem o idioma do aparelho', (tester) async {
    await pumpApp(tester, const Locale('en'));
    expect(find.text('Children'), findsWidgets);

    await pumpApp(tester, const Locale('es'));
    expect(find.text('Hijos'), findsWidgets);

    await pumpApp(tester, const Locale('pt', 'PT'));
    expect(find.text('Definições'), findsOneWidget);
  });
}
