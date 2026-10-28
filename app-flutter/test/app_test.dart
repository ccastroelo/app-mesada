import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/features/auth_family/domain/entities/family.dart';

import 'support/fakes.dart';
import 'support/pump_app.dart';

void main() {
  FakeAuthRepository signedIn() => FakeAuthRepository(user: testUser);
  FakeFamilyRepository withFamily() => FakeFamilyRepository(
    family: const Family(id: 'f1', name: 'Família Castro'),
  );

  Finder inAppBar(String text) =>
      find.descendant(of: find.byType(AppBar), matching: find.text(text));
  Finder inNavBar(String text) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(text),
  );

  testWidgets('abre em Filhos e navega pelos 3 destinos', (tester) async {
    await pumpApp(tester, auth: signedIn(), family: withFamily());

    expect(inAppBar('Filhos'), findsOneWidget);

    await tester.tap(inNavBar('Regras'));
    await tester.pumpAndSettle();
    expect(inAppBar('Regras'), findsOneWidget);

    await tester.tap(inNavBar('Ajustes'));
    await tester.pumpAndSettle();
    expect(inAppBar('Ajustes'), findsOneWidget);
  });

  testWidgets('textos seguem o idioma do aparelho', (tester) async {
    await pumpApp(
      tester,
      auth: signedIn(),
      family: withFamily(),
      locale: const Locale('en'),
    );
    expect(find.text('Children'), findsWidgets);

    await tester.pumpWidget(const SizedBox());
    await pumpApp(
      tester,
      auth: signedIn(),
      family: withFamily(),
      locale: const Locale('es'),
    );
    expect(find.text('Hijos'), findsWidgets);

    await tester.pumpWidget(const SizedBox());
    await pumpApp(
      tester,
      auth: signedIn(),
      family: withFamily(),
      locale: const Locale('pt', 'PT'),
    );
    expect(find.text('Definições'), findsOneWidget);
  });
}
