import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/core/error/failure.dart';
import 'package:mesada/core/error/result.dart';
import 'package:mesada/features/auth_family/domain/entities/family.dart';

import '../../../support/fakes.dart';
import '../../../support/pump_app.dart';

void main() {
  Finder inAppBar(String text) =>
      find.descendant(of: find.byType(AppBar), matching: find.text(text));

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  group('sem login', () {
    testWidgets('abre nas boas-vindas', (tester) async {
      await pumpApp(
        tester,
        auth: FakeAuthRepository(),
        family: FakeFamilyRepository(),
      );
      expect(find.text('Continuar com o Google'), findsOneWidget);
      expect(find.text('Entrar com e-mail'), findsOneWidget);
    });

    testWidgets('valida e-mail e senha antes de enviar', (tester) async {
      final auth = FakeAuthRepository();
      await pumpApp(tester, auth: auth, family: FakeFamilyRepository());

      await tapText(tester, 'Entrar com e-mail');
      await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Digite um e-mail válido.'), findsOneWidget);
      expect(
        find.text('A senha precisa ter pelo menos 6 caracteres.'),
        findsOneWidget,
      );
      expect(auth.calls, isEmpty);
    });

    testWidgets('credencial errada mostra o erro e continua na tela', (
      tester,
    ) async {
      final auth = FakeAuthRepository()
        ..nextResult = const Err(InvalidCredentials());
      await pumpApp(tester, auth: auth, family: FakeFamilyRepository());

      await tapText(tester, 'Entrar com e-mail');
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'ana@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'segredo1');
      await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('E-mail ou senha incorretos.'), findsOneWidget);
      expect(inAppBar('Entrar'), findsOneWidget);
    });

    testWidgets('entrar com e-mail leva à escolha de família', (tester) async {
      final auth = FakeAuthRepository();
      await pumpApp(tester, auth: auth, family: FakeFamilyRepository());

      await tapText(tester, 'Entrar com e-mail');
      await tester.enterText(
        find.byType(TextFormField).at(0),
        ' ana@example.com ',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'segredo1');
      await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
      await tester.pumpAndSettle();

      expect(auth.calls, ['signIn:ana@example.com']);
      expect(inAppBar('Sua família'), findsOneWidget);
    });

    testWidgets('alternar para criar conta usa o cadastro', (tester) async {
      final auth = FakeAuthRepository();
      await pumpApp(tester, auth: auth, family: FakeFamilyRepository());

      await tapText(tester, 'Entrar com e-mail');
      await tapText(tester, 'Não tem conta? Criar conta');
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'bia@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'segredo1');
      await tester.tap(find.widgetWithText(FilledButton, 'Criar conta'));
      await tester.pumpAndSettle();

      expect(auth.calls, ['signUp:bia@example.com']);
    });

    testWidgets('Google entra sem passar pela tela de e-mail', (tester) async {
      final auth = FakeAuthRepository();
      await pumpApp(tester, auth: auth, family: FakeFamilyRepository());

      await tapText(tester, 'Continuar com o Google');

      expect(auth.calls, ['google']);
      expect(inAppBar('Sua família'), findsOneWidget);
    });

    testWidgets('cancelar o Google não mostra erro', (tester) async {
      final auth = FakeAuthRepository()..nextResult = const Err(Cancelled());
      await pumpApp(tester, auth: auth, family: FakeFamilyRepository());

      await tapText(tester, 'Continuar com o Google');

      expect(find.text('Continuar com o Google'), findsOneWidget);
      expect(find.text('Algo deu errado. Tente de novo.'), findsNothing);
    });
  });

  group('logado sem família', () {
    FakeAuthRepository auth() => FakeAuthRepository(user: testUser);

    testWidgets('mostra os dois caminhos', (tester) async {
      await pumpApp(tester, auth: auth(), family: FakeFamilyRepository());
      expect(inAppBar('Sua família'), findsOneWidget);
      expect(find.text('Criar uma família'), findsOneWidget);
      expect(find.text('Tenho um código'), findsOneWidget);
    });

    testWidgets('criar família semeia as 20 regras no idioma e abre o app', (
      tester,
    ) async {
      final family = FakeFamilyRepository();
      await pumpApp(tester, auth: auth(), family: family);

      await tapText(tester, 'Criar uma família');
      await tester.tap(find.widgetWithText(FilledButton, 'Criar família'));
      await tester.pumpAndSettle();
      expect(find.text('Digite um nome.'), findsOneWidget);
      expect(family.lastName, isNull);

      await tester.enterText(find.byType(TextFormField), 'Família Castro');
      await tester.tap(find.widgetWithText(FilledButton, 'Criar família'));
      await tester.pumpAndSettle();

      expect(family.lastName, 'Família Castro');
      expect(family.lastSeeds, hasLength(20));
      expect(family.lastSeeds!.first.description, 'Arrumar a cama');
      expect(inAppBar('Filhos'), findsOneWidget);
    });

    testWidgets('as regras-padrão seguem o idioma do aparelho', (tester) async {
      final family = FakeFamilyRepository();
      await pumpApp(
        tester,
        auth: auth(),
        family: family,
        locale: const Locale('en'),
      );

      await tapText(tester, 'Create a family');
      await tester.enterText(find.byType(TextFormField), 'The Smiths');
      await tester.tap(find.widgetWithText(FilledButton, 'Create family'));
      await tester.pumpAndSettle();

      expect(family.lastSeeds!.first.description, 'Make the bed');
    });

    testWidgets('falha ao criar mostra o erro e não entra', (tester) async {
      final family = FakeFamilyRepository()
        ..createError = const Err(NoConnection());
      await pumpApp(tester, auth: auth(), family: family);

      await tapText(tester, 'Criar uma família');
      await tester.enterText(find.byType(TextFormField), 'Família Castro');
      await tester.tap(find.widgetWithText(FilledButton, 'Criar família'));
      await tester.pumpAndSettle();

      expect(find.text('Sem conexão. Tente de novo.'), findsOneWidget);
      expect(inAppBar('Nova família'), findsOneWidget);
    });

    testWidgets('código errado mostra erro; código certo entra', (
      tester,
    ) async {
      final family = FakeFamilyRepository(validCodes: {'ABC234'});
      await pumpApp(tester, auth: auth(), family: family);

      await tapText(tester, 'Tenho um código');
      await tester.enterText(find.byType(TextField), 'zzz999');
      await tester.tap(find.widgetWithText(FilledButton, 'Entrar na família'));
      await tester.pumpAndSettle();
      expect(
        find.text('Código inválido, expirado ou já usado.'),
        findsOneWidget,
      );

      await tester.enterText(find.byType(TextField), 'abc-234');
      await tester.tap(find.widgetWithText(FilledButton, 'Entrar na família'));
      await tester.pumpAndSettle();
      expect(inAppBar('Filhos'), findsOneWidget);
    });

    testWidgets('sair volta às boas-vindas', (tester) async {
      await pumpApp(tester, auth: auth(), family: FakeFamilyRepository());

      await tester.tap(find.byTooltip('Sair'));
      await tester.pumpAndSettle();

      expect(find.text('Continuar com o Google'), findsOneWidget);
    });
  });

  group('com família', () {
    testWidgets('Ajustes mostra família e conta, convida e sai', (
      tester,
    ) async {
      final auth = FakeAuthRepository(user: testUser);
      final family = FakeFamilyRepository(
        family: const Family(id: 'f1', name: 'Família Castro'),
      );
      await pumpApp(tester, auth: auth, family: family);

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Ajustes'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Família Castro'), findsOneWidget);
      expect(find.text('ana@example.com'), findsOneWidget);

      await tapText(tester, 'Convidar outro responsável');
      expect(find.text('ABC234'), findsOneWidget);
      expect(find.text('Copiar'), findsOneWidget);
      expect(find.text('Compartilhar'), findsOneWidget);
      await tapText(tester, 'Fechar');
      expect(find.text('ABC234'), findsNothing);

      await tapText(tester, 'Sair');
      expect(find.text('Continuar com o Google'), findsOneWidget);
      expect(auth.calls, ['signOut']);
    });
  });
}
