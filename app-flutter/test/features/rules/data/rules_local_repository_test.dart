import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/core/storage/local_store.dart';
import 'package:mesada/features/rules/data/repositories/rules_local_repository.dart';
import 'package:mesada/features/rules/rules.dart';

void main() {
  late Directory base;
  late LocalStore store;
  late RulesLocalRepository repository;

  setUp(() {
    base = Directory.systemTemp.createTempSync('mesada_rules_');
    store = LocalStore(() async => base);
    repository = RulesLocalRepository(store);
  });

  tearDown(() => base.deleteSync(recursive: true));

  void seed(Map<String, dynamic> document) => File(
    '${base.path}${Platform.pathSeparator}mesada.json',
  ).writeAsStringSync(jsonEncode(document));

  Future<List<Rule>> rules() => repository.watchRules('local').first;

  test('a lista sai na ordem do campo order, não na do arquivo', () async {
    seed({
      'rules': [
        {'id': 'r2', 'description': 'Luz acesa', 'valueCents': -50, 'order': 1},
        {'id': 'r1', 'description': 'Cama', 'valueCents': 50, 'order': 0},
      ],
    });

    expect([for (final rule in await rules()) rule.id], ['r1', 'r2']);
  });

  test('adicionar entra no fim, com a descrição aparada', () async {
    await repository.addRule('local', description: 'Cama', valueCents: 50);
    await repository.addRule('local', description: '  Luz  ', valueCents: -50);

    final list = await rules();
    expect([for (final rule in list) rule.description], ['Cama', 'Luz']);
    expect(list.last.valueCents, -50);
  });

  test('editar troca descrição e valor da regra certa', () async {
    await repository.addRule('local', description: 'Cama', valueCents: 50);
    await repository.addRule('local', description: 'Luz', valueCents: -50);
    final first = (await rules()).first;

    await repository.updateRule(
      'local',
      first.copyWith(description: 'Arrumar a cama', valueCents: 75),
    );

    final list = await rules();
    expect(list.first.description, 'Arrumar a cama');
    expect(list.first.valueCents, 75);
    expect(list.last.description, 'Luz');
  });

  test('excluir apaga a regra e só os lançamentos dela', () async {
    seed({
      'rules': [
        {'id': 'r1', 'description': 'Cama', 'valueCents': 50, 'order': 0},
        {'id': 'r2', 'description': 'Luz', 'valueCents': -50, 'order': 1},
      ],
      'entries': [
        {'childId': 'c1', 'ruleId': 'r1', 'quantity': 2},
        {'childId': 'c1', 'ruleId': 'r2', 'quantity': 1},
      ],
    });

    await repository.deleteRule('local', 'r1');

    expect([for (final rule in await rules()) rule.id], ['r2']);
    final document = await store.watch().first;
    expect(document.entries.single['ruleId'], 'r2');
  });

  test('reordenar grava 0..n-1 na ordem pedida', () async {
    seed({
      'rules': [
        {'id': 'r1', 'description': 'Cama', 'valueCents': 50, 'order': 0},
        {'id': 'r2', 'description': 'Luz', 'valueCents': -50, 'order': 1},
        {'id': 'r3', 'description': 'Nota', 'valueCents': 150, 'order': 2},
      ],
    });

    await repository.reorder('local', ['r3', 'r1', 'r2']);

    expect([for (final rule in await rules()) rule.id], ['r3', 'r1', 'r2']);
    final document = await store.watch().first;
    expect(
      {for (final rule in document.rules) rule['id']: rule['order']},
      {'r1': 1, 'r2': 2, 'r3': 0},
    );
  });

  test('usar sugestões acrescenta na ordem das sementes', () async {
    await repository.addSuggestions('local', const [
      RuleSeed('Cama', 50),
      RuleSeed('Luz', -50),
    ]);

    expect(
      [for (final rule in await rules()) rule.description],
      ['Cama', 'Luz'],
    );
  });
}
