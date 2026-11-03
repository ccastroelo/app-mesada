import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/core/error/result.dart';
import 'package:mesada/core/storage/local_store.dart';
import 'package:mesada/features/children/children.dart';
import 'package:mesada/features/children/data/repositories/children_local_repository.dart';

void main() {
  late Directory base;
  late LocalStore store;
  late ChildrenLocalRepository repository;

  setUp(() {
    base = Directory.systemTemp.createTempSync('mesada_children_');
    store = LocalStore(() async => base);
    repository = ChildrenLocalRepository(store);
  });

  tearDown(() => base.deleteSync(recursive: true));

  void seed(Map<String, dynamic> document) => File(
    '${base.path}${Platform.pathSeparator}mesada.json',
  ).writeAsStringSync(jsonEncode(document));

  Future<List<Child>> children() => repository.watchChildren('local').first;

  Future<String> add(String name, {int allowanceCents = 10000}) async {
    final result = await repository.addChild(
      'local',
      name: name,
      email: '',
      allowanceCents: allowanceCents,
    );
    return (result as Ok<String>).value;
  }

  test('adicionar devolve o id novo (a foto local usa esse id)', () async {
    final id = await add('Lucas');

    final list = await children();
    expect(id, isNotEmpty);
    expect(list.single.id, id);
    expect(list.single.name, 'Lucas');
    expect(list.single.allowanceCents, 10000);
  });

  test('a lista sai na ordem do campo order', () async {
    seed({
      'children': [
        {'id': 'c2', 'name': 'Ana', 'allowanceCents': 6000, 'order': 1},
        {'id': 'c1', 'name': 'Lucas', 'allowanceCents': 10000, 'order': 0},
      ],
    });

    expect(
      [for (final child in await children()) child.name],
      ['Lucas', 'Ana'],
    );
  });

  test('editar troca nome, e-mail e mesada', () async {
    final id = await add('Lucas');

    await repository.updateChild(
      'local',
      Child(
        id: id,
        name: 'Lucas Castro',
        allowanceCents: 12000,
        email: 'lucas@example.com',
      ),
    );

    final child = (await children()).single;
    expect(child.name, 'Lucas Castro');
    expect(child.allowanceCents, 12000);
    expect(child.email, 'lucas@example.com');
  });

  test('excluir apaga o filho e só os lançamentos dele', () async {
    seed({
      'children': [
        {'id': 'c1', 'name': 'Lucas', 'allowanceCents': 10000, 'order': 0},
        {'id': 'c2', 'name': 'Ana', 'allowanceCents': 6000, 'order': 1},
      ],
      'entries': [
        {'childId': 'c1', 'ruleId': 'r1', 'quantity': 2},
        {'childId': 'c2', 'ruleId': 'r1', 'quantity': 1},
      ],
    });

    await repository.deleteChild('local', 'c1');

    expect([for (final child in await children()) child.id], ['c2']);
    final document = await store.watch().first;
    expect(document.entries.single['childId'], 'c2');
  });

  test('reordenar grava 0..n-1 na ordem pedida', () async {
    seed({
      'children': [
        {'id': 'c1', 'name': 'Lucas', 'allowanceCents': 10000, 'order': 0},
        {'id': 'c2', 'name': 'Ana', 'allowanceCents': 6000, 'order': 1},
      ],
    });

    await repository.reorder('local', ['c2', 'c1']);

    expect(
      [for (final child in await children()) child.name],
      ['Ana', 'Lucas'],
    );
  });
}
