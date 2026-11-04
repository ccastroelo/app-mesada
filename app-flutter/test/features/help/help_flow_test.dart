import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/core/storage/device_settings.dart';
import 'package:mesada/features/auth_family/domain/entities/family.dart';
import 'package:mesada/features/help/data/repositories/intro_store_impl.dart';

import '../../support/fakes.dart';
import '../../support/pump_app.dart';

void main() {
  late FakeIntroStore intro;

  Future<void> openApp(WidgetTester tester, {bool seen = true}) async {
    intro = FakeIntroStore(wasSeen: seen);
    await pumpApp(
      tester,
      auth: FakeAuthRepository(user: testUser),
      family: FakeFamilyRepository(
        family: const Family(id: 'f1', name: 'Família Castro'),
      ),
      introStore: intro,
    );
  }

  Finder inAppBar(String text) =>
      find.descendant(of: find.byType(AppBar), matching: find.text(text));

  Future<void> openHelp(WidgetTester tester) async {
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Ajustes'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(ListTile, 'Introdução, contato e sobre'),
    );
    await tester.pumpAndSettle();
  }

  group('introdução', () {
    testWidgets('no primeiro uso, aparece antes do app', (tester) async {
      await openApp(tester, seen: false);

      expect(find.text('Seus filhos'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('já vista, o app abre direto', (tester) async {
      await openApp(tester);

      expect(find.text('Seus filhos'), findsNothing);
      expect(inAppBar('Filhos'), findsOneWidget);
    });

    testWidgets('Pular marca como vista e leva ao app', (tester) async {
      await openApp(tester, seen: false);

      await tester.tap(find.widgetWithText(TextButton, 'Pular'));
      await tester.pumpAndSettle();

      expect(intro.wasSeen, isTrue);
      expect(inAppBar('Filhos'), findsOneWidget);
    });

    testWidgets('os 4 cartões, e Começar no último', (tester) async {
      await openApp(tester, seen: false);

      for (final title in ['As regras', 'Lançar', 'Os dois responsáveis']) {
        await tester.tap(find.widgetWithText(FilledButton, 'Próximo'));
        await tester.pumpAndSettle();
        expect(find.text(title), findsOneWidget);
      }

      await tester.tap(find.widgetWithText(FilledButton, 'Começar'));
      await tester.pumpAndSettle();

      expect(intro.wasSeen, isTrue);
      expect(inAppBar('Filhos'), findsOneWidget);
    });
  });

  group('Ajustes › Ajuda', () {
    testWidgets('dá para rever a introdução depois', (tester) async {
      await openApp(tester);
      await openHelp(tester);

      await tester.tap(find.text('Ver introdução'));
      await tester.pumpAndSettle();

      expect(find.text('Seus filhos'), findsOneWidget);
    });

    testWidgets('o contato copia o e-mail e avisa', (tester) async {
      await openApp(tester);
      await openHelp(tester);

      expect(find.text('contato@ideiasmob.com.br'), findsOneWidget);
      await tester.tap(find.text('Falar com a gente'));
      await tester.pumpAndSettle();

      expect(find.text('E-mail copiado'), findsOneWidget);
    });

    testWidgets('Sobre diz onde os dados ficam', (tester) async {
      await openApp(tester);
      await openHelp(tester);

      expect(find.text('Os dados ficam neste aparelho.'), findsOneWidget);
    });
  });

  group('marca no aparelho', () {
    test('fica no device.json, junto do PIN, sem apagar nada', () async {
      final base = Directory.systemTemp.createTempSync('mesada_intro_');
      addTearDown(() => base.deleteSync(recursive: true));
      final settings = DeviceSettings(() async => base);
      await settings.merge({'pinHash': 'abc'});
      final store = IntroStoreImpl(settings);

      expect(await store.seen(), isFalse);
      await store.markSeen();

      expect(await store.seen(), isTrue);
      expect(await settings.read(), {'pinHash': 'abc', 'introSeen': true});
    });
  });
}
