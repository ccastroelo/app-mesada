/// Superfície pública (só domínio) da feature `ledger` para outras features.
/// O estado fica em `ledger_providers.dart` (depende de `auth_family`).
library;

export 'domain/entities/entry.dart';
export 'domain/repositories/ledger_repository.dart';
export 'domain/usecases/calculate_balance.dart';
