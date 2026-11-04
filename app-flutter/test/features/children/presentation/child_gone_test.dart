import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/features/auth_family/domain/entities/family.dart';
import 'package:mesada/features/children/children.dart';
import 'package:mesada/features/rules/rules.dart';

import '../../../support/fakes.dart';
import '../../../support/pump_app.dart';

const _lucas = Child(id: 'c1', name: 'Lucas', allowanceCents: 10000);
const _ana = Child(id: 'c2', name: 'Ana', allowanceCents: 6000);
const _bed = Rule(id: 'r1', description: 'Arrumar a cama', valueCents: 50);

/// O outro responsável exclui o filho enquanto a tela dele está aberta (só
/// acontece com assinatura).
void main() {
  late FakeChildrenRepository children;

  Future<void> open(WidgetTester tester) async {
    children = FakeChildrenRepository(children: const [_lucas, _ana]);
    await pumpApp(
      tester,
      auth: FakeAuthRepository(user: testUser),
      family: FakeFamilyRepository(
        family: const Family(id: 'f1', name: 'Família Castro'),
      ),
      children: children,
      rules: FakeRulesRepository(rules: const [_bed]),
    );
  }

  testWidgets('na tela do filho: volta à lista e avisa', (tester) async {
    await open(tester);
    await tester.tap(find.text('Lucas'));
    await tester.pumpAndSettle();
    expect(find.byType(BackButton), findsOneWidget);

    await children.deleteChild('f1', 'c1');
    await tester.pumpAndSettle();

    expect(find.byType(BackButton), findsNothing);
    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('Lucas'), findsNothing);
    expect(
      find.text('Este filho foi removido pelo outro responsável.'),
      findsOneWidget,
    );
    // Nada do estado de erro genérico.
    expect(find.text('Tentar de novo'), findsNothing);
  });

  testWidgets('nas regras do filho: também volta à lista', (tester) async {
    await open(tester);
    await tester.tap(find.text('Lucas'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_vert).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Regras deste filho'));
    await tester.pumpAndSettle();

    await children.deleteChild('f1', 'c1');
    await tester.pumpAndSettle();

    expect(find.byType(BackButton), findsNothing);
    expect(find.text('Ana'), findsOneWidget);
    expect(
      find.text('Este filho foi removido pelo outro responsável.'),
      findsOneWidget,
    );
  });

  testWidgets('excluir outro filho não tira ninguém da tela', (tester) async {
    await open(tester);
    await tester.tap(find.text('Lucas'));
    await tester.pumpAndSettle();

    await children.deleteChild('f1', 'c2');
    await tester.pumpAndSettle();

    expect(find.byType(BackButton), findsOneWidget);
    expect(find.text('Arrumar a cama'), findsOneWidget);
    expect(find.textContaining('foi removido'), findsNothing);
  });
}
