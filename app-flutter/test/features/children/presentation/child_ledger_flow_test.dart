import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/features/auth_family/domain/entities/family.dart';
import 'package:mesada/features/children/children.dart';
import 'package:mesada/features/ledger/ledger.dart';
import 'package:mesada/features/rules/rules.dart';

import '../../../support/fakes.dart';
import '../../../support/pump_app.dart';

const _lucas = Child(id: 'c1', name: 'Lucas', allowanceCents: 10000);
const _ana = Child(id: 'c2', name: 'Ana', allowanceCents: 6000);
const _bed = Rule(id: 'r1', description: 'Arrumar a cama', valueCents: 50);
const _grade = Rule(id: 'r2', description: 'Tirar nota 10', valueCents: 150);
const _light = Rule(id: 'r3', description: 'Luz acesa', valueCents: -50);

void main() {
  late FakeLedgerRepository ledger;

  /// Abre a aba Filhos e toca no cartão de [childName] para entrar nos
  /// lançamentos.
  Future<void> openLedger(
    WidgetTester tester, {
    String childName = 'Lucas',
    List<Child> children = const [_lucas],
    List<Rule> rules = const [_bed, _grade, _light],
    List<Entry> entries = const [],
  }) async {
    ledger = FakeLedgerRepository(entries: entries);
    await pumpApp(
      tester,
      auth: FakeAuthRepository(user: testUser),
      family: FakeFamilyRepository(
        family: const Family(id: 'f1', name: 'Família Castro'),
      ),
      children: FakeChildrenRepository(children: children),
      rules: FakeRulesRepository(rules: rules),
      ledger: ledger,
    );
    await tester.tap(find.text(childName));
    await tester.pumpAndSettle();
  }

  Finder inAppBar(String text) =>
      find.descendant(of: find.byType(AppBar), matching: find.text(text));

  /// O botão + ou − da linha da regra [description]; o tooltip é o rótulo do
  /// leitor de tela, e o botão é o widget que o envolve.
  Finder stepper(String description, {required bool increase}) => find.ancestor(
    of: find.byTooltip(
      increase
          ? RegExp('^Aumentar $description,')
          : RegExp('^Diminuir $description,'),
    ),
    matching: find.byType(IconButton),
  );

  /// O formato de moeda usa espaço não-quebrável depois do símbolo.
  String money(String amount) => 'R\$ $amount';

  /// O chip do último lançamento, junto ao saldo (único `Wrap` da tela).
  Finder chip(String text) =>
      find.descendant(of: find.byType(Wrap), matching: find.text(text));

  Future<void> tapMenu(WidgetTester tester, String item) async {
    await tester.tap(find.byIcon(Icons.more_vert).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(item));
    await tester.pumpAndSettle();
  }

  group('tela do filho', () {
    testWidgets('o cartão abre os lançamentos, em duas seções', (tester) async {
      await openLedger(tester);

      expect(inAppBar('Lucas'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      expect(find.text('Recompensas'), findsOneWidget);
      expect(find.text('Descontos'), findsOneWidget);
      expect(find.text('Arrumar a cama'), findsOneWidget);
      expect(find.text('Luz acesa'), findsOneWidget);
      // Mesada e saldo no cabeçalho: nada lançado ainda.
      expect(find.text('Mesada ${money('100,00')}'), findsOneWidget);
      expect(find.text(money('100,00')), findsOneWidget);
    });

    testWidgets('+ lança, o saldo muda na hora e o chip aparece', (
      tester,
    ) async {
      await openLedger(tester);

      await tester.tap(stepper('Arrumar a cama', increase: true));
      await tester.pumpAndSettle();

      expect(ledger.calls, ['increment:c1_r1']);
      expect(find.text(money('100,50')), findsOneWidget);
      // O mesmo texto é o valor da regra na linha; o do cabeçalho é o chip.
      expect(chip('+${money('0,50')}'), findsOneWidget);
    });

    testWidgets('lançar um desconto baixa o saldo', (tester) async {
      await openLedger(tester);

      await tester.tap(stepper('Luz acesa', increase: true));
      await tester.pumpAndSettle();

      expect(find.text(money('99,50')), findsOneWidget);
      expect(chip('−${money('0,50')}'), findsOneWidget);
    });

    testWidgets('− fica desabilitado em 0 e volta a ligar depois do +', (
      tester,
    ) async {
      await openLedger(tester);

      expect(
        tester
            .widget<IconButton>(stepper('Arrumar a cama', increase: false))
            .onPressed,
        isNull,
      );

      await tester.tap(stepper('Arrumar a cama', increase: true));
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<IconButton>(stepper('Arrumar a cama', increase: false))
            .onPressed,
        isNotNull,
      );

      await tester.tap(stepper('Arrumar a cama', increase: false));
      await tester.pumpAndSettle();

      expect(ledger.calls, ['increment:c1_r1', 'decrement:c1_r1']);
      expect(find.text(money('100,00')), findsOneWidget);
    });

    testWidgets('regra desativada para o filho não aparece', (tester) async {
      await openLedger(
        tester,
        entries: const [
          Entry(childId: 'c1', ruleId: 'r3', quantity: 2, enabled: false),
        ],
      );

      expect(find.text('Luz acesa'), findsNothing);
      expect(find.text('Descontos'), findsNothing);
      // Quantidade guardada, fora do saldo (ADR-0008).
      expect(find.text(money('100,00')), findsOneWidget);
    });

    testWidgets('sem regra nenhuma, convida a criar', (tester) async {
      await openLedger(tester, rules: const []);

      expect(find.text('Nenhuma regra para lançar'), findsOneWidget);
    });

    testWidgets('com todas desativadas, leva às regras do filho', (
      tester,
    ) async {
      await openLedger(
        tester,
        rules: const [_bed],
        entries: const [Entry(childId: 'c1', ruleId: 'r1', enabled: false)],
      );

      expect(
        find.text('Todas as regras estão desativadas para Lucas'),
        findsOneWidget,
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Regras deste filho'));
      await tester.pumpAndSettle();
      expect(inAppBar('Regras deste filho'), findsOneWidget);
    });
  });

  group('regras deste filho', () {
    testWidgets('o switch desativa e a quantidade continua guardada', (
      tester,
    ) async {
      await openLedger(
        tester,
        entries: const [Entry(childId: 'c1', ruleId: 'r1', quantity: 4)],
      );
      expect(find.text(money('102,00')), findsOneWidget);

      await tapMenu(tester, 'Regras deste filho');
      expect(find.byType(SwitchListTile), findsNWidgets(3));

      await tester.tap(
        find.descendant(
          of: find.widgetWithText(SwitchListTile, 'Arrumar a cama'),
          matching: find.byType(Switch),
        ),
      );
      await tester.pumpAndSettle();

      expect(ledger.calls, ['setEnabled:c1_r1:false']);
      expect(ledger.entries.single.quantity, 4);

      // `pageBack` procura o tooltip "Back"; aqui a interface está em pt-BR.
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Arrumar a cama'), findsNothing);
      expect(find.text(money('100,00')), findsOneWidget);
    });
  });

  group('zerar', () {
    testWidgets('pede confirmação, zera e oferece Desfazer', (tester) async {
      await openLedger(
        tester,
        entries: const [Entry(childId: 'c1', ruleId: 'r1', quantity: 4)],
      );

      await tapMenu(tester, 'Zerar lançamentos');
      expect(find.text('Zerar lançamentos de Lucas?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Zerar'));
      await tester.pumpAndSettle();

      expect(ledger.entries.single.quantity, 0);
      expect(find.text(money('100,00')), findsOneWidget);
      expect(find.text('Lançamentos zerados'), findsOneWidget);

      await tester.tap(find.text('Desfazer'));
      await tester.pumpAndSettle();

      expect(ledger.entries.single.quantity, 4);
      expect(find.text(money('102,00')), findsOneWidget);
    });

    testWidgets('cancelar não zera nada', (tester) async {
      await openLedger(
        tester,
        entries: const [Entry(childId: 'c1', ruleId: 'r1', quantity: 4)],
      );

      await tapMenu(tester, 'Zerar lançamentos');
      await tester.tap(find.widgetWithText(TextButton, 'Cancelar'));
      await tester.pumpAndSettle();

      expect(ledger.entries.single.quantity, 4);
      expect(ledger.calls, isEmpty);
    });

    testWidgets('a aba Filhos zera os lançamentos de todos', (tester) async {
      ledger = FakeLedgerRepository(
        entries: const [
          Entry(childId: 'c1', ruleId: 'r1', quantity: 4),
          Entry(childId: 'c2', ruleId: 'r1', quantity: 2),
        ],
      );
      await pumpApp(
        tester,
        auth: FakeAuthRepository(user: testUser),
        family: FakeFamilyRepository(
          family: const Family(id: 'f1', name: 'Família Castro'),
        ),
        children: FakeChildrenRepository(children: const [_lucas, _ana]),
        rules: FakeRulesRepository(rules: const [_bed]),
        ledger: ledger,
      );

      // O menu da barra superior, não o de um cartão.
      await tester.tap(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.more_vert),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Zerar lançamentos de todos'));
      await tester.pumpAndSettle();

      expect(
        find.text('Zerar lançamentos de todos os filhos?'),
        findsOneWidget,
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Zerar'));
      await tester.pumpAndSettle();

      expect([for (final e in ledger.entries) e.quantity], [0, 0]);
      expect(find.text('Lançamentos zerados'), findsOneWidget);
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

        await openLedger(
          tester,
          children: const [
            Child(
              id: 'c1',
              name: 'Maria Eduarda de Albuquerque Castro',
              allowanceCents: 123456,
            ),
          ],
          childName: 'Maria Eduarda de Albuquerque Castro',
          rules: const [
            Rule(
              id: 'r1',
              description: 'Deixar roupa ou toalha largada no chão',
              valueCents: -50,
            ),
          ],
          entries: const [Entry(childId: 'c1', ruleId: 'r1', quantity: 999)],
        );
        expect(tester.takeException(), isNull);

        await tester.tap(
          stepper('Deixar roupa ou toalha largada no chão', increase: true),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await tapMenu(tester, 'Regras deste filho');
        expect(tester.takeException(), isNull);
      });
    }
  });
}
