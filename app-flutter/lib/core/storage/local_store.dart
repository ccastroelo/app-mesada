import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../error/failure.dart';
import '../error/result.dart';
import 'local_document.dart';

/// Guarda o documento do app num único arquivo JSON e publica cada mudança
/// (ADR-0014). É o único ponto que toca o disco no modo local — o equivalente
/// ao datasource do Firestore.
///
/// A gravação é atômica (escreve `.tmp` e renomeia), então uma queda no meio
/// nunca deixa arquivo pela metade, e as escritas são aplicadas na ordem em
/// que chegam. A mudança vale em memória **antes** do disco: a tela reage no
/// mesmo quadro, como o design pede.
class LocalStore {
  LocalStore(this._baseDirectory, {this.fileName = 'mesada.json'});

  final Future<Directory> Function() _baseDirectory;
  final String fileName;

  final _changes = StreamController<LocalDocument>.broadcast();
  Future<LocalDocument>? _current;
  Future<void> _queue = Future.value();

  /// O documento de agora e cada mudança seguinte.
  ///
  /// Arquivo ilegível vira erro no stream (o portão mostra a tela de erro):
  /// é melhor avisar do que começar vazio e dar os dados por perdidos.
  Stream<LocalDocument> watch() async* {
    yield await _load();
    yield* _changes.stream;
  }

  /// Lê o arquivo uma vez e guarda o resultado. Se a leitura falhar, **não**
  /// guarda a falha: quem tentar de novo (depois de [startOver] ou de a
  /// pessoa consertar o arquivo) lê outra vez em vez de herdar o erro.
  Future<LocalDocument> _load() {
    final loading = _current ??= _readOrCreate();
    loading.then<void>(
      (_) {},
      onError: (_) {
        if (identical(_current, loading)) _current = null;
      },
    );
    return loading;
  }

  /// Saída de um arquivo ilegível: guarda o arquivo ruim ao lado, como
  /// `<nome>.bak` (o anterior, se houver, é substituído), e passa a valer um
  /// documento vazio. O arquivo novo só é criado na primeira gravação.
  ///
  /// Nada é apagado: quem quiser pode recuperar o `.bak` à mão.
  Future<Result<void>> startOver() {
    final done = _queue.then((_) => _startOver());
    _queue = done.then((_) {}, onError: (_) {});
    return done;
  }

  Future<Result<void>> _startOver() async {
    try {
      final file = await _file();
      if (file.existsSync()) {
        final backup = File('${file.path}.bak');
        if (backup.existsSync()) await backup.delete();
        await file.rename(backup.path);
      }
      final empty = LocalDocument.initial();
      _current = Future.value(empty);
      _changes.add(empty);
      return const Ok(null);
    } catch (error) {
      return Err(Unexpected(error));
    }
  }

  /// Aplica [change], publica e grava. Falha de disco volta como [Err] e o que
  /// está na tela continua valendo (a pessoa não perde o toque).
  Future<Result<void>> update(LocalDocument Function(LocalDocument) change) {
    final applied = _queue.then((_) => _apply(change));
    // A fila segue mesmo se uma gravação falhar.
    _queue = applied.then((_) {}, onError: (_) {});
    return applied;
  }

  Future<Result<void>> _apply(
    LocalDocument Function(LocalDocument) change,
  ) async {
    final document = change(await _load());
    _current = Future.value(document);
    _changes.add(document);
    try {
      await _write(document);
      return const Ok(null);
    } catch (error) {
      return Err(Unexpected(error));
    }
  }

  Future<LocalDocument> _readOrCreate() async {
    final file = await _file();
    if (!file.existsSync()) return LocalDocument.initial();
    final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    return LocalDocument.fromJson(json);
  }

  Future<void> _write(LocalDocument document) async {
    final file = await _file();
    await file.parent.create(recursive: true);
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(jsonEncode(document.toJson()), flush: true);
    await temporary.rename(file.path);
  }

  Future<File> _file() async {
    final base = await _baseDirectory();
    return File('${base.path}${Platform.pathSeparator}$fileName');
  }
}
