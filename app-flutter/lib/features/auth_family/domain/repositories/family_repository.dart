import '../../../../core/error/result.dart';
import '../../../rules/rules.dart';
import '../entities/app_user.dart';
import '../entities/family.dart';

abstract class FamilyRepository {
  /// Id da família do usuário, ou null se ainda não entrou em nenhuma.
  Stream<String?> watchFamilyId(String uid);

  Stream<Family?> watchFamily(String familyId);

  /// Cria a família, torna [user] membro e semeia as [rules] iniciais.
  /// Se só a semeadura falhar, a família existe e o resultado é Ok: a pessoa
  /// repõe as sugestões na aba Regras.
  Future<Result<void>> createFamily({
    required AppUser user,
    required String name,
    required List<RuleSeed> rules,
  });

  /// Gera um código de convite (uso único, validade curta) e o devolve.
  Future<Result<String>> createInvite({
    required AppUser user,
    required Family family,
  });

  Future<Result<void>> joinWithCode({
    required AppUser user,
    required String code,
  });
}
