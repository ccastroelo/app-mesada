import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/core/storage/device_settings.dart';

void main() {
  late Directory base;
  late DeviceSettings settings;

  setUp(() {
    base = Directory.systemTemp.createTempSync('mesada_device_');
    settings = DeviceSettings(() async => base);
  });

  tearDown(() => base.deleteSync(recursive: true));

  File file() => File('${base.path}${Platform.pathSeparator}device.json');

  test('sem arquivo, nenhum ajuste', () async {
    expect(await settings.read(), isEmpty);
    expect(file().existsSync(), isFalse);
  });

  test('gravar uma chave não apaga as outras', () async {
    await settings.merge({'pinHash': 'abc'});
    await settings.merge({'biometricsEnabled': true});

    expect(await settings.read(), {
      'pinHash': 'abc',
      'biometricsEnabled': true,
    });
  });

  test('valor nulo apaga a chave', () async {
    await settings.merge({'pinHash': 'abc', 'biometricsEnabled': true});

    await settings.merge({'pinHash': null});

    expect(await settings.read(), {'biometricsEnabled': true});
  });

  test(
    'arquivo ruim conta como nenhum ajuste e dá para gravar em cima',
    () async {
      file().writeAsStringSync('isto não é json');

      expect(await settings.read(), isEmpty);
      await settings.merge({'pinHash': 'abc'});
      expect(await settings.read(), {'pinHash': 'abc'});
    },
  );
}
