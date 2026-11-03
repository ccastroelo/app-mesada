import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/core/storage/local_store.dart';
import 'package:mesada/features/ledger/data/repositories/ledger_local_repository.dart';
import 'package:mesada/features/ledger/ledger.dart';

void main() {
  late Directory base;
  late LocalStore store;
  late LedgerLocalRepository repository;

  setUp(() {
    base = Directory.systemTemp.createTempSync('mesada_ledger_');
    store = LocalStore(() async => base);
    repository = LedgerLocalRepository(store);
  });

  tearDown(() => base.deleteSync(recursive: true));

  void seed(Map<String, dynamic> document) => File(
    '${base.path}${Platform.pathSeparator}mesada.json',
  ).writeAsStringSync(jsonEncode(document));

  Future<List<Entry>> entries() => repository.watchEntries('local').first;

  Future<Entry?> entry(String childId, String ruleId) async {
    for (final found in await entries()) {
      if (found.childId == childId && found.ruleId == ruleId) return found;
    }
    return null;
  }

  test('o lançamento nasce no primeiro + (ADR-0013)', () async {
    expect(await entries(), isEmpty);

    await repository.increment('local', childId: 'c1', ruleId: 'r1');

    final created = await entry('c1', 'r1');
    expect(created?.quantity, 1);
    expect(created?.enabled, isTrue);
    expect((await entries()).length, 1);
  });

  test('+ soma e não mexe nos outros pares', () async {
    await repository.increment('local', childId: 'c1', ruleId: 'r1');
    await repository.increment('local', childId: 'c1', ruleId: 'r1');
    await repository.increment('local', childId: 'c2', ruleId: 'r1');

    expect((await entry('c1', 'r1'))?.quantity, 2);
    expect((await entry('c2', 'r1'))?.quantity, 1);
  });

  test('− tem piso 0 e nunca fica negativo', () async {
    await repository.increment('local', childId: 'c1', ruleId: 'r1');
    await repository.decrement('local', childId: 'c1', ruleId: 'r1');
    await repository.decrement('local', childId: 'c1', ruleId: 'r1');

    expect((await entry('c1', 'r1'))?.quantity, 0);
  });

  test('− em par que não existe não cria quantidade negativa', () async {
    await repository.decrement('local', childId: 'c1', ruleId: 'r1');

    expect((await entry('c1', 'r1'))?.quantity, 0);
  });

  test('desativar guarda a quantidade (ADR-0008)', () async {
    seed({
      'entries': [
        {'childId': 'c1', 'ruleId': 'r1', 'quantity': 3, 'enabled': true},
      ],
    });

    await repository.setEnabled(
      'local',
      childId: 'c1',
      ruleId: 'r1',
      enabled: false,
    );

    final disabled = await entry('c1', 'r1');
    expect(disabled?.enabled, isFalse);
    expect(disabled?.quantity, 3);

    await repository.setEnabled(
      'local',
      childId: 'c1',
      ruleId: 'r1',
      enabled: true,
    );
    expect((await entry('c1', 'r1'))?.quantity, 3);
  });

  test('zerar um filho não toca nos outros nem no enabled', () async {
    seed({
      'entries': [
        {'childId': 'c1', 'ruleId': 'r1', 'quantity': 3, 'enabled': false},
        {'childId': 'c2', 'ruleId': 'r1', 'quantity': 5, 'enabled': true},
      ],
    });

    await repository.zero('local', childId: 'c1');

    final zeroed = await entry('c1', 'r1');
    expect(zeroed?.quantity, 0);
    expect(zeroed?.enabled, isFalse);
    expect((await entry('c2', 'r1'))?.quantity, 5);
  });

  test('zerar sem filho zera todos', () async {
    seed({
      'entries': [
        {'childId': 'c1', 'ruleId': 'r1', 'quantity': 3},
        {'childId': 'c2', 'ruleId': 'r2', 'quantity': 5},
      ],
    });

    await repository.zero('local');

    expect([for (final found in await entries()) found.quantity], [0, 0]);
  });

  test('desfazer repõe as quantidades que havia', () async {
    seed({
      'entries': [
        {'childId': 'c1', 'ruleId': 'r1', 'quantity': 3},
        {'childId': 'c1', 'ruleId': 'r2', 'quantity': 1},
      ],
    });
    final previous = await entries();

    await repository.zero('local', childId: 'c1');
    await repository.restore('local', previous);

    expect((await entry('c1', 'r1'))?.quantity, 3);
    expect((await entry('c1', 'r2'))?.quantity, 1);
  });
}
