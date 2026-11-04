/// Superfície pública (só domínio) da feature `app_lock`.
/// O estado fica em `app_lock_providers.dart`.
library;

export 'domain/repositories/biometric_auth.dart';
export 'domain/repositories/pin_recovery_service.dart';
export 'domain/repositories/pin_store.dart';
export 'domain/usecases/pin_lock_rules.dart';
