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

  /// Cria a família já com o conteúdo deste aparelho, em vez de semear as
  /// regras-padrão: a virada de fonte de verdade do ADR-0014. Recebe só
  /// primitivos para não amarrar esta feature às outras.
  Future<Result<void>> createFamilyFromLocal({
    required AppUser user,
    required String name,
    required Map<String, Object?> plan,
    required List<Map<String, dynamic>> children,
    required List<Map<String, dynamic>> rules,
    required List<Map<String, dynamic>> entries,
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
