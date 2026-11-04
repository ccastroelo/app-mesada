import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/core/error/failure.dart';
import 'package:mesada/core/error/result.dart';
import 'package:mesada/core/storage/local_document.dart';
import 'package:mesada/core/storage/local_store.dart';
import 'package:mesada/features/auth_family/data/repositories/local_family_source.dart';

void main() {
  late Directory base;
  late LocalStore store;

  setUp(() {
    base = Directory.systemTemp.createTempSync('mesada_store_');
    store = LocalStore(() async => base);
  });

  tearDown(() => base.deleteSync(recursive: true));

  File file() => File('${base.path}${Platform.pathSeparator}mesada.json');

  void write(String content) => file().writeAsStringSync(content);

  Future<Result<void>> addRule(String id) => store.update(
    (d) => d.copyWith(
      rules: [
        ...d.rules,
        {'id': id},
      ],
    ),
  );

  test('primeira abertura: família local vazia, sem criar arquivo', () async {
    final document = await store.watch().first;

    expect(document.familyId, LocalDocument.localFamilyId);
    expect(document.family['name'], '');
    expect(document.rules, isEmpty);
    expect(document.children, isEmpty);
    expect(document.entries, isEmpty);
    expect(file().existsSync(), isFalse);
  });

  test('gravar vale na leitura seguinte e cria o arquivo', () async {
    expect(await addRule('r1'), isA<Ok<void>>());

    final document = await store.watch().first;
    expect(document.rules.single['id'], 'r1');

    final json = jsonDecode(file().readAsStringSync()) as Map<String, dynamic>;
    expect(json['schemaVersion'], LocalDocument.schemaVersion);
    expect((json['rules'] as List).single, {'id': 'r1'});
  });

  test('outro store na mesma pasta lê o que foi gravado', () async {
    await addRule('r1');

    final other = LocalStore(() async => base);
    final document = await other.watch().first;

    expect(document.rules.single['id'], 'r1');
  });

  test('a mudança chega a quem já está ouvindo', () async {
    final seen = <int>[];
    final subscription = store.watch().listen((d) => seen.add(d.rules.length));
    addTearDown(subscription.cancel);
    await pumpEventQueue();

    await addRule('r1');
    await pumpEventQueue();

    expect(seen, [0, 1]);
  });

  test('escritas disparadas juntas não se perdem', () async {
    await Future.wait([addRule('r1'), addRule('r2')]);

    final document = await store.watch().first;
    expect([for (final rule in document.rules) rule['id']], ['r1', 'r2']);
  });

  test(
    'erro de gravação volta como Err sem desfazer o que está na tela',
    () async {
      // Uma pasta no lugar do arquivo faz a gravação falhar.
      Directory(
        '${base.path}${Platform.pathSeparator}mesada.json',
      ).createSync();

      final result = await addRule('r1');

      expect(result, isA<Err<void>>());
      expect((result as Err<void>).failure, isA<Unexpected>());
      expect((await store.watch().first).rules.single['id'], 'r1');
    },
  );

  test('arquivo ilegível vira erro no stream, sem apagar nada', () async {
    write('isto não é json');

    await expectLater(store.watch().first, throwsA(anything));
    expect(file().readAsStringSync(), 'isto não é json');
  });

  group('arquivo ilegível: saída', () {
    File backup() => File('${file().path}.bak');

    test('ler de novo depois de consertar não herda o erro', () async {
      write('isto não é json');
      await expectLater(store.watch().first, throwsA(anything));

      write(
        jsonEncode({
          'rules': [
            {'id': 'r1'},
          ],
        }),
      );

      expect((await store.watch().first).rules.single['id'], 'r1');
    });

    test(
      'começar de novo guarda o arquivo ruim como .bak e abre vazio',
      () async {
        write('isto não é json');
        await expectLater(store.watch().first, throwsA(anything));

        final result = await store.startOver();

        expect(result, isA<Ok<void>>());
        expect(backup().readAsStringSync(), 'isto não é json');
        expect(file().existsSync(), isFalse);
        final document = await store.watch().first;
        expect(document.rules, isEmpty);
        expect(document.familyId, LocalDocument.localFamilyId);
      },
    );

    test(
      'depois de recomeçar, gravar cria o arquivo novo e mantém o .bak',
      () async {
        write('isto não é json');
        await store.startOver();

        await addRule('r1');

        expect(file().existsSync(), isTrue);
        expect(backup().readAsStringSync(), 'isto não é json');
        expect((await store.watch().first).rules.single['id'], 'r1');
      },
    );

    test('um .bak antigo é substituído', () async {
      backup().writeAsStringSync('velho');
      write('{"rules": 1');

      await store.startOver();

      expect(backup().readAsStringSync(), '{"rules": 1');
    });

    test('sem arquivo não há o que guardar e continua vazio', () async {
      final result = await store.startOver();

      expect(result, isA<Ok<void>>());
      expect(backup().existsSync(), isFalse);
      expect((await store.watch().first).rules, isEmpty);
    });

    test('o stream aberto recebe o documento vazio', () async {
      write(
        jsonEncode({
          'rules': [
            {'id': 'r1'},
          ],
        }),
      );
      final seen = <int>[];
      final subscription = store.watch().listen(
        (document) => seen.add(document.rules.length),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await store.startOver();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await subscription.cancel();

      expect(seen, [1, 0]);
    });
  });

  group('nome da família', () {
    test('renomear grava no arquivo e aparece na leitura seguinte', () async {
      final source = LocalFamilySource(store);

      final result = await source.rename('  Família Castro ');

      expect(result, isA<Ok<void>>());
      expect((await source.watchFamily().first).name, 'Família Castro');
      expect(
        (jsonDecode(file().readAsStringSync()) as Map)['family'],
        containsPair('name', 'Família Castro'),
      );
    });

    test('nome vazio volta ao padrão e o id continua local', () async {
      final source = LocalFamilySource(store);
      await source.rename('Castro');

      await source.rename('   ');

      final family = await source.watchFamily().first;
      expect(family.name, '');
      expect(family.id, LocalDocument.localFamilyId);
    });
  });

  test('campo ausente ou com tipo errado cai no padrão', () async {
    write(
      jsonEncode({
        'family': 7,
        'rules': 'x',
        'children': [
          1,
          {'id': 'c1'},
        ],
      }),
    );

    final document = await store.watch().first;

    expect(document.familyId, LocalDocument.localFamilyId);
    expect(document.rules, isEmpty);
    expect(document.children.single['id'], 'c1');
  });
}
