import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/features/app_lock/app_lock.dart';
import 'package:mesada/features/app_lock/data/repositories/pin_store_impl.dart';

void main() {
  late Directory base;
  late PinStoreImpl store;

  setUp(() {
    base = Directory.systemTemp.createTempSync('mesada_pin_');
    store = PinStoreImpl(() async => base);
  });

  tearDown(() => base.deleteSync(recursive: true));

  File file() => File('${base.path}${Platform.pathSeparator}device.json');

  test('sem arquivo, não há PIN', () async {
    expect(await store.read(), isNull);
    expect(file().existsSync(), isFalse);
  });

  test('guarda e lê sal e hash, num arquivo separado do mesada.json', () async {
    await store.save(const PinCredential(salt: 'abc', hash: 'def'));

    final saved = await store.read();
    expect(saved?.salt, 'abc');
    expect(saved?.hash, 'def');
    expect(file().existsSync(), isTrue);
    expect(
      File('${base.path}${Platform.pathSeparator}mesada.json').existsSync(),
      isFalse,
    );
  });

  test('desativar apaga a credencial', () async {
    await store.save(const PinCredential(salt: 'abc', hash: 'def'));

    await store.clear();

    expect(await store.read(), isNull);
  });

  test('arquivo ruim conta como sem PIN, para não trancar o app', () async {
    file().writeAsStringSync('isto não é json');

    expect(await store.read(), isNull);
  });

  test('arquivo sem as chaves conta como sem PIN', () async {
    file().writeAsStringSync('{"outraCoisa": 1}');

    expect(await store.read(), isNull);
  });
}
