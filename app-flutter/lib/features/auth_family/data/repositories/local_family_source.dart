import '../../../../core/error/result.dart';
import '../../../../core/storage/local_store.dart';
import '../../domain/entities/family.dart';
import '../models/family_dto.dart';

/// A família do modo local (ADR-0014): vem do arquivo do aparelho, sem conta.
///
/// Não implementa `FamilyRepository` de propósito: criar família, convidar e
/// entrar por código só existem com conta, no fluxo da assinatura (ADR-0015).
class LocalFamilySource {
  LocalFamilySource(this._store);

  final LocalStore _store;

  Stream<Family> watchFamily() => _store.watch().map(
    (document) =>
        FamilyDto.fromMap(document.familyId, document.family).toEntity(),
  );

  /// Dá (ou troca) o nome da família deste aparelho. Nome vazio volta ao
  /// padrão do idioma.
  Future<Result<void>> rename(String name) => _store.update(
    (document) =>
        document.copyWith(family: {...document.family, 'name': name.trim()}),
  );

  /// Saída de um arquivo ilegível (ver `LocalStore.startOver`).
  Future<Result<void>> startOver() => _store.startOver();
}
