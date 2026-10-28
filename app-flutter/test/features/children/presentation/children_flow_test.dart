import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/core/error/failure.dart';
import 'package:mesada/core/error/result.dart';
import 'package:mesada/features/auth_family/domain/entities/family.dart';
import 'package:mesada/features/children/children.dart';
import 'package:mesada/features/ledger/ledger.dart';
import 'package:mesada/features/rules/rules.dart';

import '../../../support/fakes.dart';
import '../../../support/pump_app.dart';

const _lucas = Child(id: 'c1', name: 'Lucas', allowanceCents: 10000);
const _ana = Child(
  id: 'c2',
  name: 'Ana',
  allowanceCents: 6000,
  email: 'ana@example.com',
);
const _bed = Rule(id: 'r1', description: 'Arrumar a cama', valueCents: 50);
const _light = Rule(id: 'r2', description: 'Luz acesa', valueCents: -50);

/// O formato de moeda usa espaço não-quebrável só depois do símbolo.
String money(String text) => text.replaceAll('R\$ ', 'R\$ ');

void main() {
  late FakeChildrenRepository repository;
  late FakePhotoStore store;
  late FakePhotoPicker picker;
  late FakeLedgerRepository ledger;

  Future<void> openChildren(
    WidgetTester tester, {
    List<Child> children = const [],
    List<Rule> rules = const [],
    List<Entry> entries = const [],
  }) async {
    repository = FakeChildrenRepository(children: children);
    store = FakePhotoStore();
    picker = FakePhotoPicker();
    ledger = FakeLedgerRepository(entries: entries);
    await pumpApp(
      tester,
      auth: FakeAuthRepository(user: testUser),
      family: FakeFamilyRepository(
        family: const Family(id: 'f1', name: 'Família Castro'),
      ),
      rules: FakeRulesRepository(rules: rules),
      children: repository,
      ledger: ledger,
      photoStore: store,
      photoPicker: picker,
    );
  }

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  group('lista', () {
    testWidgets('vazia convida a adicionar o primeiro filho', (tester) async {
      await openChildren(tester);
      expect(
        find.text('Adicione o primeiro filho para começar'),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Adicionar filho'));
      await tester.pumpAndSettle();
      expect(find.text('Novo filho'), findsOneWidget);
    });

    testWidgets('cartão mostra nome, mesada e saldo = mesada sem lançamentos', (
      tester,
    ) async {
      await openChildren(tester, children: [_lucas]);
      expect(find.text('Lucas'), findsOneWidget);
      expect(find.text(money('Mesada R\$ 100,00')), findsOneWidget);
      expect(find.text('Saldo'), findsOneWidget);
      expect(find.text(money('R\$ 100,00')), findsOneWidget);
      expect(find.text('L'), findsOneWidget); // avatar com a inicial
    });

    testWidgets('saldo soma recompensas e subtrai descontos por quantidade', (
      tester,
    ) async {
      await openChildren(
        tester,
        children: [_lucas],
        rules: [_bed, _light],
        entries: const [
          Entry(childId: 'c1', ruleId: 'r1', quantity: 3), // +1,50
          Entry(childId: 'c1', ruleId: 'r2', quantity: 2), // -1,00
        ],
      );
      expect(find.text(money('R\$ 100,50')), findsOneWidget);
    });

    testWidgets('regra desativada para o filho não conta no saldo', (
      tester,
    ) async {
      await openChildren(
        tester,
        children: [_lucas],
        rules: [_light],
        entries: const [
          Entry(childId: 'c1', ruleId: 'r2', quantity: 4, enabled: false),
        ],
      );
      // O saldo continua sendo só a mesada.
      expect(find.text(money('R\$ 100,00')), findsOneWidget);
    });

    testWidgets('saldo negativo vem com sinal de menos e seta para baixo', (
      tester,
    ) async {
      await openChildren(
        tester,
        children: [const Child(id: 'c9', name: 'Bia', allowanceCents: 100)],
        rules: [_light],
        entries: const [Entry(childId: 'c9', ruleId: 'r2', quantity: 5)],
      );
      expect(find.text('−R\$ 1,50'), findsOneWidget);
      expect(find.byIcon(Icons.trending_down), findsOneWidget);
    });

    testWidgets('o saldo acompanha os lançamentos em tempo real', (
      tester,
    ) async {
      await openChildren(tester, children: [_lucas], rules: [_bed]);
      expect(find.text(money('R\$ 100,00')), findsOneWidget);

      // O outro responsável lança +2: o stream de lançamentos emite.
      ledger.entries = const [Entry(childId: 'c1', ruleId: 'r1', quantity: 2)];
      await tester.pumpAndSettle();

      expect(find.text(money('R\$ 101,00')), findsOneWidget);
      expect(find.text(money('Mesada R\$ 100,00')), findsOneWidget);
    });
  });

  group('criar e editar', () {
    testWidgets('cria com máscara de centavos e a lista passa a mostrá-lo', (
      tester,
    ) async {
      await openChildren(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Adicionar filho'));
      await tester.pumpAndSettle();

      await tester.enterText(field('Nome'), '  Lucas ');
      await tester.enterText(field('Mesada'), '10000');
      expect(find.text('100,00'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
      await tester.pumpAndSettle();

      expect(repository.children.single.name, 'Lucas');
      expect(repository.children.single.allowanceCents, 10000);
      expect(repository.children.single.email, '');
      expect(find.text(money('Mesada R\$ 100,00')), findsOneWidget);
    });

    testWidgets(
      'nome vazio e e-mail inválido não salvam; e-mail em branco pode',
      (tester) async {
        await openChildren(tester);
        await tester.tap(find.widgetWithText(FilledButton, 'Adicionar filho'));
        await tester.pumpAndSettle();

        await tester.enterText(field('E-mail (opcional)'), 'isso-nao-e-email');
        await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
        await tester.pumpAndSettle();
        expect(find.text('Digite o nome.'), findsOneWidget);
        expect(
          find.text('Digite um e-mail válido ou deixe em branco.'),
          findsOneWidget,
        );
        expect(repository.children, isEmpty);

        await tester.enterText(field('Nome'), 'Lucas');
        await tester.enterText(field('E-mail (opcional)'), '');
        await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
        await tester.pumpAndSettle();
        expect(repository.children, hasLength(1));
      },
    );

    testWidgets('falha ao salvar mostra o erro e fica na tela', (tester) async {
      await openChildren(tester);
      repository.nextResult = const Err(NoConnection());
      await tester.tap(find.widgetWithText(FilledButton, 'Adicionar filho'));
      await tester.pumpAndSettle();
      await tester.enterText(field('Nome'), 'Lucas');
      await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
      await tester.pumpAndSettle();
      expect(find.text('Sem conexão. Tente de novo.'), findsOneWidget);
      expect(find.text('Novo filho'), findsOneWidget);
    });

    testWidgets('editar abre preenchido e atualiza no lugar', (tester) async {
      await openChildren(tester, children: [_lucas, _ana]);

      await tester.tap(find.byIcon(Icons.more_vert).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Editar'));
      await tester.pumpAndSettle();

      expect(find.text('Editar filho'), findsOneWidget);
      expect(
        tester.widget<TextFormField>(field('Nome')).controller!.text,
        'Ana',
      );
      expect(find.text('ana@example.com'), findsOneWidget);
      expect(find.text('60,00'), findsOneWidget);

      await tester.enterText(field('Nome'), 'Ana Clara');
      await tester.enterText(field('Mesada'), '7550');
      await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
      await tester.pumpAndSettle();

      expect(repository.children.map((c) => c.id), ['c1', 'c2']);
      expect(repository.children.last.name, 'Ana Clara');
      expect(repository.children.last.allowanceCents, 7550);
      expect(repository.children.last.email, 'ana@example.com');
    });
  });

  group('foto local', () {
    testWidgets(
      'escolher na galeria grava no aparelho, no id do filho criado',
      (tester) async {
        await openChildren(tester);
        await tester.tap(find.widgetWithText(FilledButton, 'Adicionar filho'));
        await tester.pumpAndSettle();

        picker.next = '/tmp/escolhida.jpg';
        await tester.enterText(field('Nome'), 'Lucas');
        await tester.runAsync(() async {
          await tester.tap(find.text('Escolher foto'));
        });
        await tester.pump();
        expect(find.text('Remover foto'), findsOneWidget);

        await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
        await tester.pumpAndSettle();

        expect(store.saved.single, (
          childId: 'c1',
          source: '/tmp/escolhida.jpg',
        ));
      },
    );

    testWidgets('cancelar a galeria não muda nada', (tester) async {
      await openChildren(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Adicionar filho'));
      await tester.pumpAndSettle();
      picker.next = null;
      await tester.tap(find.text('Escolher foto'));
      await tester.pumpAndSettle();
      expect(find.text('Remover foto'), findsNothing);
    });

    testWidgets('sem foto escolhida nada é gravado', (tester) async {
      await openChildren(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Adicionar filho'));
      await tester.pumpAndSettle();
      await tester.enterText(field('Nome'), 'Lucas');
      await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
      await tester.pumpAndSettle();
      expect(store.saved, isEmpty);
      expect(store.deleted, isEmpty);
    });
  });

  group('excluir', () {
    Future<void> openMenuAndDelete(WidgetTester tester) async {
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Excluir'));
      await tester.pumpAndSettle();
    }

    testWidgets('pede confirmação, remove e apaga a foto local', (
      tester,
    ) async {
      await openChildren(tester, children: [_lucas, _ana]);

      await openMenuAndDelete(tester);
      expect(find.text('Excluir Lucas?'), findsOneWidget);
      expect(
        find.text('Isso remove também todos os lançamentos dele.'),
        findsOneWidget,
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Excluir'));
      await tester.pumpAndSettle();

      expect(repository.children.map((c) => c.id), ['c2']);
      expect(store.deleted, ['c1']);
      expect(find.text('Filho excluído'), findsOneWidget);
    });

    testWidgets('cancelar não apaga nada', (tester) async {
      await openChildren(tester, children: [_lucas]);
      await openMenuAndDelete(tester);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(repository.deleteCalls, 0);
      expect(store.deleted, isEmpty);
    });
  });

  group('reordenar', () {
    testWidgets('com um filho só não oferece reordenar', (tester) async {
      await openChildren(tester, children: [_lucas]);
      expect(find.byTooltip('Reordenar'), findsNothing);
    });

    testWidgets('arrastar muda a ordem e Concluir grava', (tester) async {
      await openChildren(tester, children: [_lucas, _ana]);
      await tester.tap(find.byTooltip('Reordenar'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.drag_handle), findsNWidgets(2));
      expect(find.text('Adicionar filho'), findsNothing);

      await tester.drag(
        find.byIcon(Icons.drag_handle).first,
        const Offset(0, 200),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Concluir'));
      await tester.pumpAndSettle();

      expect(repository.lastReorder, ['c2', 'c1']);
      expect(find.byIcon(Icons.drag_handle), findsNothing);
    });

    testWidgets('Concluir sem mexer não grava', (tester) async {
      await openChildren(tester, children: [_lucas, _ana]);
      await tester.tap(find.byTooltip('Reordenar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Concluir'));
      await tester.pumpAndSettle();
      expect(repository.lastReorder, isNull);
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

        await openChildren(
          tester,
          children: [
            const Child(
              id: 'c9',
              name: 'Maria Eduarda de Albuquerque Castro',
              allowanceCents: 123456,
            ),
            _ana,
          ],
          rules: [_light],
          entries: const [Entry(childId: 'c2', ruleId: 'r2', quantity: 999)],
        );
        expect(tester.takeException(), isNull);

        await tester.tap(find.byTooltip('Reordenar'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Concluir'));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.more_vert).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Editar'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.widgetWithText(FilledButton, 'Salvar'), findsOneWidget);
      });
    }
  });
}
