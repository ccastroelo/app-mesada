import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/core/error/failure.dart';
import 'package:mesada/core/error/result.dart';
import 'package:mesada/features/auth_family/domain/entities/family.dart';
import 'package:mesada/features/rules/rules.dart';

import '../../../support/fakes.dart';
import '../../../support/pump_app.dart';

const _bed = Rule(id: 'r1', description: 'Arrumar a cama', valueCents: 50);
const _light = Rule(
  id: 'r2',
  description: 'Deixar a luz acesa',
  valueCents: -50,
);
const _lie = Rule(id: 'r3', description: 'Mentir', valueCents: -100);

void main() {
  Future<FakeRulesRepository> openRules(
    WidgetTester tester, {
    List<Rule> rules = const [],
    Locale locale = const Locale('pt', 'BR'),
  }) async {
    final repository = FakeRulesRepository(rules: rules);
    await pumpApp(
      tester,
      auth: FakeAuthRepository(user: testUser),
      family: FakeFamilyRepository(
        family: const Family(id: 'f1', name: 'Família Castro'),
      ),
      rules: repository,
      locale: locale,
    );
    final regras = locale.languageCode == 'en' ? 'Rules' : 'Regras';
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(regras),
      ),
    );
    await tester.pumpAndSettle();
    return repository;
  }

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  group('lista', () {
    testWidgets('vazia convida a usar as sugestões e semeia as 20 do idioma', (
      tester,
    ) async {
      final repository = await openRules(tester);
      expect(find.text('Nenhuma regra ainda'), findsOneWidget);

      await tester.tap(find.text('Usar sugestões'));
      await tester.pumpAndSettle();

      expect(repository.rules, hasLength(20));
      expect(repository.rules.first.description, 'Arrumar a cama');
      expect(find.text('Nenhuma regra ainda'), findsNothing);
      expect(find.text('Recompensas'), findsOneWidget);
      expect(find.text('Descontos'), findsOneWidget);
    });

    testWidgets('as sugestões seguem o idioma do aparelho', (tester) async {
      final repository = await openRules(tester, locale: const Locale('en'));
      await tester.tap(find.text('Use suggestions'));
      await tester.pumpAndSettle();
      expect(repository.rules.first.description, 'Make the bed');
    });

    testWidgets('agrupa em recompensas e descontos, com valor e sinal', (
      tester,
    ) async {
      await openRules(tester, rules: [_light, _bed, _lie]);

      expect(find.text('Recompensas'), findsOneWidget);
      expect(find.text('Descontos'), findsOneWidget);
      expect(find.text('Recompensa · +R\$ 0,50'), findsOneWidget);
      expect(find.text('Desconto · −R\$ 0,50'), findsOneWidget);
      expect(find.text('Desconto · −R\$ 1,00'), findsOneWidget);
      // recompensa vem antes dos descontos
      expect(
        tester.getTopLeft(find.text('Arrumar a cama')).dy,
        lessThan(tester.getTopLeft(find.text('Deixar a luz acesa')).dy),
      );
    });

    testWidgets('mostra o erro se a escrita falhar', (tester) async {
      final repository = await openRules(tester);
      repository.nextResult = const Err(NoConnection());
      await tester.tap(find.text('Usar sugestões'));
      await tester.pumpAndSettle();
      expect(find.text('Sem conexão. Tente de novo.'), findsOneWidget);
      expect(repository.rules, isEmpty);
    });
  });

  group('criar e editar', () {
    testWidgets('cria uma recompensa com a máscara de centavos', (
      tester,
    ) async {
      final repository = await openRules(tester, rules: [_light]);

      await tester.tap(find.text('Nova regra'));
      await tester.pumpAndSettle();
      expect(find.text('0,00'), findsOneWidget);

      await tester.enterText(field('Descrição'), '  Tirar nota 10 ');
      await tester.tap(find.text('Recompensa'));
      await tester.pump();
      await tester.enterText(field('Valor'), '150');
      expect(find.text('1,50'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
      await tester.pumpAndSettle();

      final created = repository.rules.last;
      expect(created.description, 'Tirar nota 10');
      expect(created.valueCents, 150);
      expect(find.text('Tirar nota 10'), findsOneWidget);
      expect(find.text('Recompensa · +R\$ 1,50'), findsOneWidget);
    });

    testWidgets('desconto grava valor negativo; zero é permitido', (
      tester,
    ) async {
      final repository = await openRules(tester);
      repository.nextResult = const Ok(null);

      await tester.tap(find.text('Nova regra'));
      await tester.pumpAndSettle();
      await tester.enterText(field('Descrição'), 'Mentir');
      await tester.enterText(field('Valor'), '75');
      await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
      await tester.pumpAndSettle();
      expect(repository.rules.single.valueCents, -75);

      await tester.tap(find.text('Nova regra'));
      await tester.pumpAndSettle();
      await tester.enterText(field('Descrição'), 'Neutra');
      await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
      await tester.pumpAndSettle();
      expect(repository.rules.last.valueCents, 0);
    });

    testWidgets('descrição vazia não salva', (tester) async {
      final repository = await openRules(tester);
      await tester.tap(find.text('Nova regra'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
      await tester.pumpAndSettle();
      expect(find.text('Digite uma descrição.'), findsOneWidget);
      expect(repository.rules, isEmpty);
    });

    testWidgets('teto de 999,99 rejeita mais dígitos', (tester) async {
      await openRules(tester);
      await tester.tap(find.text('Nova regra'));
      await tester.pumpAndSettle();
      await tester.enterText(field('Valor'), '99999');
      expect(find.text('999,99'), findsOneWidget);
      await tester.enterText(field('Valor'), '999999');
      expect(find.text('999,99'), findsOneWidget);
    });

    testWidgets('editar abre preenchido e atualiza no lugar', (tester) async {
      final repository = await openRules(tester, rules: [_bed, _light]);

      await tester.tap(find.text('Deixar a luz acesa'));
      await tester.pumpAndSettle();
      expect(find.text('Editar regra'), findsOneWidget);
      expect(
        tester.widget<TextFormField>(field('Descrição')).controller!.text,
        'Deixar a luz acesa',
      );
      expect(find.text('0,50'), findsOneWidget);

      await tester.enterText(field('Descrição'), 'Deixar a luz acesa à toa');
      await tester.enterText(field('Valor'), '100');
      await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
      await tester.pumpAndSettle();

      expect(repository.rules.map((r) => r.id), ['r1', 'r2']);
      expect(repository.rules.last.description, 'Deixar a luz acesa à toa');
      expect(repository.rules.last.valueCents, -100);
    });

    testWidgets('trocar o tipo na edição inverte o sinal', (tester) async {
      final repository = await openRules(tester, rules: [_light]);
      await tester.tap(find.text('Deixar a luz acesa'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Recompensa'));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
      await tester.pumpAndSettle();
      expect(repository.rules.single.valueCents, 50);
    });
  });

  group('excluir', () {
    Future<void> openMenuAndDelete(WidgetTester tester) async {
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Excluir'));
      await tester.pumpAndSettle();
    }

    testWidgets('pede confirmação e remove', (tester) async {
      final repository = await openRules(tester, rules: [_bed, _light]);

      await openMenuAndDelete(tester);
      expect(find.text('Excluir “Arrumar a cama”?'), findsOneWidget);
      expect(
        find.text('Isso remove os lançamentos dessa regra de todos os filhos.'),
        findsOneWidget,
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Excluir'));
      await tester.pumpAndSettle();

      expect(repository.rules.map((r) => r.id), ['r2']);
      expect(find.text('Regra excluída'), findsOneWidget);
    });

    testWidgets('cancelar não apaga nada', (tester) async {
      final repository = await openRules(tester, rules: [_bed]);

      await openMenuAndDelete(tester);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(repository.deleteCalls, 0);
      expect(repository.rules, hasLength(1));
    });
  });

  group('fonte grande em tela pequena (flutter-ui)', () {
    for (final scale in [1.3, 2.0]) {
      testWidgets('sem overflow a ${scale}x', (tester) async {
        tester.view
          ..physicalSize = const Size(360, 640)
          ..devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        await openRules(tester, rules: [_bed, _light, _lie]);
        expect(tester.takeException(), isNull);

        await tester.tap(find.byTooltip('Reordenar'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Concluir'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Nova regra'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.widgetWithText(FilledButton, 'Salvar'), findsOneWidget);
      });
    }
  });

  group('reordenar', () {
    testWidgets('com uma regra só não oferece reordenar', (tester) async {
      await openRules(tester, rules: [_bed]);
      expect(find.byTooltip('Reordenar'), findsNothing);
    });

    testWidgets('arrastar muda a ordem e Concluir grava', (tester) async {
      final repository = await openRules(tester, rules: [_bed, _light, _lie]);

      await tester.tap(find.byTooltip('Reordenar'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.drag_handle), findsNWidgets(3));
      expect(find.text('Nova regra'), findsNothing);

      await tester.drag(
        find.byIcon(Icons.drag_handle).first,
        const Offset(0, 300),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Concluir'));
      await tester.pumpAndSettle();

      expect(repository.lastReorder, isNotNull);
      expect(repository.lastReorder, isNot(['r1', 'r2', 'r3']));
      expect(repository.lastReorder, hasLength(3));
      expect(find.byIcon(Icons.drag_handle), findsNothing);
    });

    testWidgets('Concluir sem mexer não grava', (tester) async {
      final repository = await openRules(tester, rules: [_bed, _light]);
      await tester.tap(find.byTooltip('Reordenar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Concluir'));
      await tester.pumpAndSettle();
      expect(repository.lastReorder, isNull);
      expect(find.byIcon(Icons.drag_handle), findsNothing);
    });
  });
}
