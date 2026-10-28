/// Superfície pública (só domínio) da feature `children` para outras features.
/// O estado fica em `children_providers.dart` (depende de `auth_family`).
library;

export 'domain/entities/child.dart';
export 'domain/repositories/child_photo_store.dart';
export 'domain/repositories/children_repository.dart';
