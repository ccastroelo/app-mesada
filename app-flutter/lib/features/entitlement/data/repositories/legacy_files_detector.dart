import 'dart:io';

import '../../domain/repositories/legacy_app_detector.dart';

/// O app antigo gravava `mesadeiros.plist`, `faltas.plist` e `lancamentos.plist`
/// na pasta Documents. Como o app novo usa o mesmo bundle id (ADR-0007), essa
/// pasta é a mesma depois da atualização. No Android nunca houve app antigo,
/// então a resposta é sempre não.
///
/// Limite conhecido: o app antigo só gravava esses arquivos ao salvar algo;
/// quem o instalou e nunca salvou nada não deixa rastro.
class LegacyFilesDetector implements LegacyAppDetector {
  LegacyFilesDetector(this._documents);

  final Future<Directory> Function() _documents;

  static const files = [
    'mesadeiros.plist',
    'faltas.plist',
    'lancamentos.plist',
  ];

  @override
  Future<bool> existed() async {
    final directory = await _documents();
    for (final name in files) {
      final file = File('${directory.path}${Platform.pathSeparator}$name');
      if (await file.exists()) return true;
    }
    return false;
  }
}
