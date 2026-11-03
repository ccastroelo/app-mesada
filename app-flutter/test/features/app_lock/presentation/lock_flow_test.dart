import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/features/app_lock/app_lock.dart';
import 'package:mesada/features/auth_family/domain/entities/family.dart';

import '../../../support/fakes.dart';
import '../../../support/pump_app.dart';

void main() {
  /// Abre o app com (ou sem) um PIN já guardado neste aparelho.
  Future<FakePinStore> openApp(WidgetTester tester, {String? pin}) async {
    final store = FakePinStore();
    if (pin != null) {
      final salt = newPinSalt();
      store.credential = PinCredential(salt: salt, hash: hashPin(pin, salt));
    }
    await pumpApp(
      tester,
      auth: FakeAuthRepository(user: testUser),
      family: FakeFamilyRepository(
        family: const Family(id: 'f1', name: 'Família Castro'),
      ),
      pinStore: store,
      // Relógio parado: a contagem da espera não depende do tempo real que
      // passa entre o toque e o quadro desenhado.
      clock: () => DateTime(2026, 11, 3, 20),
    );
    return store;
  }

  Future<void> type(WidgetTester tester, String pin) async {
    for (final digit in pin.split('')) {
      await tester.tap(find.widgetWithText(OutlinedButton, digit));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  Finder inAppBar(String text) =>
      find.descendant(of: find.byType(AppBar), matching: find.text(text));

  group('tela de bloqueio', () {
    testWidgets('sem PIN, o app abre direto', (tester) async {
      await openApp(tester);

      expect(find.text('Digite seu PIN'), findsNothing);
      expect(inAppBar('Filhos'), findsOneWidget);
    });

    testWidgets('com PIN, o app abre pedindo o PIN', (tester) async {
      await openApp(tester, pin: '1234');

      expect(find.text('Digite seu PIN'), findsOneWidget);
      // O bloqueio cobre tudo: nenhuma aba aparece atrás.
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('o PIN certo abre o app', (tester) async {
      await openApp(tester, pin: '1234');

      await type(tester, '1234');

      expect(find.text('Digite seu PIN'), findsNothing);
      expect(inAppBar('Filhos'), findsOneWidget);
    });

    testWidgets('o PIN errado avisa e continua pedindo', (tester) async {
      await openApp(tester, pin: '1234');

      await type(tester, '9999');

      expect(find.text('PIN incorreto'), findsOneWidget);
      expect(find.text('Digite seu PIN'), findsOneWidget);
    });

    testWidgets('3 erros seguram as tentativas com contagem', (tester) async {
      await openApp(tester, pin: '1234');

      for (var i = 0; i < 3; i++) {
        await type(tester, '9999');
      }

      expect(find.text('Tente de novo em 0:30'), findsOneWidget);
      // As teclas ficam desabilitadas durante a espera.
      expect(
        tester
            .widget<OutlinedButton>(find.widgetWithText(OutlinedButton, '1'))
            .onPressed,
        isNull,
      );
    });
  });

  group('Ajustes › Segurança', () {
    Future<void> openSecurity(WidgetTester tester) async {
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Ajustes'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('PIN'));
      await tester.pumpAndSettle();
    }

    testWidgets('ativar pede o PIN duas vezes e guarda o hash', (tester) async {
      final store = await openApp(tester);
      await openSecurity(tester);

      expect(find.text('PIN desativado'), findsWidgets);
      await tester.tap(find.text('Ativar PIN'));
      await tester.pumpAndSettle();

      expect(find.text('Escolha um PIN de 4 dígitos'), findsOneWidget);
      await type(tester, '1234');
      expect(find.text('Digite o PIN de novo'), findsOneWidget);
      await type(tester, '1234');

      expect(find.text('PIN ativado'), findsWidgets);
      expect(store.credential, isNotNull);
      expect(store.credential!.hash, isNot(contains('1234')));
    });

    testWidgets('confirmação diferente avisa e volta a pedir', (tester) async {
      await openApp(tester);
      await openSecurity(tester);

      await tester.tap(find.text('Ativar PIN'));
      await tester.pumpAndSettle();
      await type(tester, '1234');
      await type(tester, '5678');

      expect(
        find.text('Os PINs não coincidem. Tente de novo.'),
        findsOneWidget,
      );
      expect(find.text('Escolha um PIN de 4 dígitos'), findsOneWidget);
    });

    testWidgets('desativar exige o PIN atual', (tester) async {
      final store = await openApp(tester, pin: '1234');
      await type(tester, '1234');
      await openSecurity(tester);

      await tester.tap(find.text('Desativar PIN'));
      await tester.pumpAndSettle();
      expect(find.text('Digite o PIN atual'), findsOneWidget);

      await type(tester, '9999');
      expect(find.text('PIN incorreto'), findsOneWidget);
      expect(store.credential, isNotNull);

      await type(tester, '1234');
      expect(find.text('PIN desativado'), findsWidgets);
      expect(store.credential, isNull);
    });
  });
}
