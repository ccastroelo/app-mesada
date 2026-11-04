import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/core/storage/local_store.dart';
import 'package:mesada/core/storage/providers.dart';
import 'package:mesada/features/auth_family/data/providers.dart';
import 'package:mesada/features/auth_family/presentation/state/controllers.dart';
import 'package:mesada/features/auth_family/presentation/state/gate.dart';
import 'package:mesada/features/family_plan/data/providers.dart';
import 'package:mesada/features/family_plan/family_plan.dart';

import '../../support/fakes.dart';

/// A virada de fonte de verdade (ADR-0014): criar a família leva o conteúdo
/// deste aparelho, em vez de semear as 20 regras-padrão.
///
/// Fora de teste de widget de propósito: o controlador lê o arquivo local, e
/// I/O de verdade só completa fora do relógio falso dos widgets.
void main() {
  late Directory base;
  late FakeFamilyRepository family;

  setUp(() {
    base = Directory.systemTemp.createTempSync('mesada_migration_');
    family = FakeFamilyRepository();
  });

  tearDown(() => base.deleteSync(recursive: true));

  void seedLocal(Map<String, dynamic> document) => File(
    '${base.path}${Platform.pathSeparator}mesada.json',
  ).writeAsStringSync(jsonEncode(document));

  Future<bool> createFamily({required FamilyPlan plan}) async {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          FakeAuthRepository(user: testUser),
        ),
        familyRepositoryProvider.overrideWithValue(family),
        localStoreProvider.overrideWithValue(LocalStore(() async => base)),
        planStoreProvider.overrideWithValue(FakePlanStore(plan: plan)),
      ],
    );
    addTearDown(container.dispose);
    // O controlador lê quem está logado pelo stream; ouvir e deixar a fila
    // de eventos andar resolve o primeiro valor (o `.future` do StreamProvider
    // não completa aqui).
    container.listen(authUserProvider, (_, _) {});
    await pumpEventQueue();
    // O controlador é autoDispose: sem ouvinte ele morre no primeiro await,
    // como morreria se a tela fechasse no meio.
    container.listen(createFamilyControllerProvider, (_, _) {});
    return container
        .read(createFamilyControllerProvider.notifier)
        .create('Família Castro', 'pt');
  }

  test('com plano e dados locais, a família nasce com eles', () async {
    seedLocal({
      'children': [
        {'id': 'c1', 'name': 'Lucas', 'allowanceCents': 10000, 'order': 0},
      ],
      'rules': [
        {'id': 'r1', 'description': 'Cama', 'valueCents': 50, 'order': 0},
      ],
      'entries': [
        {'childId': 'c1', 'ruleId': 'r1', 'quantity': 3, 'enabled': true},
      ],
    });

    final ok = await createFamily(
      plan: FamilyPlan.lifetime(since: DateTime(2026, 11, 3)),
    );

    expect(ok, isTrue);
    final uploaded = family.uploaded;
    expect(uploaded, isNotNull);
    expect(uploaded!.children.single['name'], 'Lucas');
    expect(uploaded.rules.single['description'], 'Cama');
    expect(uploaded.entries.single['quantity'], 3);
    // O direito sobe junto, com a marca do modelo (ADR-0020).
    expect(uploaded.plan['kind'], 'lifetime');
    expect(uploaded.plan['modelVersion'], 1);
    // E nada de regras-padrão: os dados do aparelho é que valem.
    expect(family.lastSeeds, isNull);
  });

  test('sem plano, a família nasce com as regras-padrão', () async {
    seedLocal({
      'rules': [
        {'id': 'r1', 'description': 'Cama', 'valueCents': 50, 'order': 0},
      ],
    });

    final ok = await createFamily(plan: const FamilyPlan.none());

    expect(ok, isTrue);
    expect(family.uploaded, isNull);
    expect(family.lastSeeds?.length, 20);
  });

  test('com plano mas sem nada local, também semeia', () async {
    final ok = await createFamily(
      plan: FamilyPlan.lifetime(since: DateTime(2026, 11, 3)),
    );

    expect(ok, isTrue);
    expect(family.uploaded, isNull);
    expect(family.lastSeeds?.length, 20);
  });
}
