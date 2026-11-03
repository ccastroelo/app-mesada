import 'dart:convert';
import 'dart:io';

/// Ajustes **do aparelho** num único `device.json`: hoje o PIN e a biometria
/// (ADR-0017). Fica fora do `mesada.json` de propósito — é do aparelho, não da
/// família, e não pode subir com os dados na assinatura (ADR-0014).
///
/// A leitura é defensiva (arquivo ruim conta como nenhum ajuste) e a escrita é
/// atômica e **por junção**: gravar uma chave não apaga as outras, porque mais
/// de uma parte do app guarda coisa aqui.
class DeviceSettings {
  DeviceSettings(this._baseDirectory, {this.fileName = 'device.json'});

  final Future<Directory> Function() _baseDirectory;
  final String fileName;

  Future<Map<String, Object?>> read() async {
    final file = await _file();
    if (!file.existsSync()) return {};
    try {
      final json = jsonDecode(await file.readAsString());
      return json is Map ? {...json.cast<String, Object?>()} : {};
    } catch (_) {
      return {};
    }
  }

  /// Junta [changes] ao que já está gravado. Valor nulo **apaga** a chave.
  Future<void> merge(Map<String, Object?> changes) async {
    final next = {...await read(), ...changes}
      ..removeWhere((_, value) => value == null);
    final file = await _file();
    await file.parent.create(recursive: true);
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(jsonEncode(next), flush: true);
    await temporary.rename(file.path);
  }

  Future<File> _file() async {
    final base = await _baseDirectory();
    return File('${base.path}${Platform.pathSeparator}$fileName');
  }
}
