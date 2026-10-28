import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/features/children/data/repositories/child_photo_store_impl.dart';

void main() {
  late Directory base;
  late Directory source;
  late ChildPhotoStoreImpl store;

  setUp(() {
    base = Directory.systemTemp.createTempSync('mesada_photos_');
    source = Directory.systemTemp.createTempSync('mesada_source_');
    store = ChildPhotoStoreImpl(() async => base);
  });

  tearDown(() {
    base.deleteSync(recursive: true);
    source.deleteSync(recursive: true);
  });

  File picked(String name, List<int> bytes) =>
      File('${source.path}${Platform.pathSeparator}$name')
        ..writeAsBytesSync(bytes);

  test('sem foto, o caminho é null', () async {
    expect(await store.photoPath('c1'), isNull);
  });

  test('salvar copia a imagem para a pasta do app, por id do filho', () async {
    final original = picked('a.jpg', [1, 2, 3]);
    await store.savePhoto('c1', original.path);

    final path = await store.photoPath('c1');
    expect(path, isNotNull);
    expect(path, startsWith(base.path));
    expect(path, endsWith('c1.jpg'));
    expect(File(path!).readAsBytesSync(), [1, 2, 3]);
    // a original continua onde estava (é a da galeria)
    expect(original.existsSync(), isTrue);
  });

  test('salvar de novo troca a foto; cada filho tem a sua', () async {
    await store.savePhoto('c1', picked('a.jpg', [1]).path);
    await store.savePhoto('c2', picked('b.jpg', [2]).path);
    await store.savePhoto('c1', picked('c.jpg', [9, 9]).path);

    expect(File((await store.photoPath('c1'))!).readAsBytesSync(), [9, 9]);
    expect(File((await store.photoPath('c2'))!).readAsBytesSync(), [2]);
  });

  test('apagar remove só a foto do filho e é seguro sem foto', () async {
    await store.savePhoto('c1', picked('a.jpg', [1]).path);
    await store.savePhoto('c2', picked('b.jpg', [2]).path);

    await store.deletePhoto('c1');
    await store.deletePhoto('c1');
    await store.deletePhoto('nunca-teve');

    expect(await store.photoPath('c1'), isNull);
    expect(await store.photoPath('c2'), isNotNull);
  });
}
