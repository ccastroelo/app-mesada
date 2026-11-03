import 'dart:convert';
import 'dart:io';

import '../../domain/repositories/pin_store.dart';

/// Guarda o PIN em `<pasta do app>/device.json`, **fora** do `mesada.json`:
/// é ajuste do aparelho e não pode subir com os dados da família no M4.5.
///
/// Gravação atômica (escreve `.tmp` e renomeia), como no `LocalStore`. A pasta
/// vem de fora (`path_provider` no app, pasta temporária nos testes).
class PinStoreImpl implements PinStore {
  PinStoreImpl(this._baseDirectory, {this.fileName = 'device.json'});

  final Future<Directory> Function() _baseDirectory;
  final String fileName;

  @override
  Future<PinCredential?> read() async {
    final file = await _file();
    if (!file.existsSync()) return null;
    // Arquivo é borda: ilegível ou sem as chaves conta como "sem PIN", que é o
    // lado seguro aqui — trancar o app sem poder destravar seria pior.
    try {
      final json = jsonDecode(await file.readAsString());
      if (json is! Map) return null;
      final salt = json['pinSalt'];
      final hash = json['pinHash'];
      if (salt is! String || hash is! String) return null;
      return PinCredential(salt: salt, hash: hash);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(PinCredential credential) =>
      _write({'pinSalt': credential.salt, 'pinHash': credential.hash});

  @override
  Future<void> clear() => _write(const {});

  Future<void> _write(Map<String, Object?> json) async {
    final file = await _file();
    await file.parent.create(recursive: true);
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(jsonEncode(json), flush: true);
    await temporary.rename(file.path);
  }

  Future<File> _file() async {
    final base = await _baseDirectory();
    return File('${base.path}${Platform.pathSeparator}$fileName');
  }
}
