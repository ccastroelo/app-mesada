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
}
