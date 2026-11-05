/// Superfície pública (só domínio) da feature `entitlement`: a marca de onde o
/// aparelho veio, os produtos das lojas e a regra de acesso (ADR-0021).
library;

export 'domain/entities/app_entitlement.dart';
export 'domain/entities/purchase_record.dart';
export 'domain/entities/store_product.dart';
export 'domain/repositories/entitlement_store.dart';
export 'domain/repositories/legacy_app_detector.dart';
export 'domain/repositories/purchase_store.dart';
export 'domain/repositories/secure_trial_store.dart';
export 'domain/repositories/store_gateway.dart';
export 'domain/usecases/evaluate_access.dart';
