/// Superfície pública (só domínio) da feature `entitlement`: a marca de onde o
/// aparelho veio e a regra de acesso (ADR-0021).
library;

export 'domain/entities/app_entitlement.dart';
export 'domain/repositories/entitlement_store.dart';
export 'domain/repositories/legacy_app_detector.dart';
export 'domain/usecases/evaluate_access.dart';
