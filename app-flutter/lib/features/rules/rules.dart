/// Superfície pública (só domínio) da feature `rules` para outras features.
///
/// O estado (`rulesProvider`) fica de fora de propósito: ele depende de
/// `auth_family`, que por sua vez importa este arquivo.
library;

export 'domain/default_rules.dart';
export 'domain/entities/rule.dart';
export 'domain/repositories/rules_repository.dart';
export 'domain/usecases/split_rules.dart';
