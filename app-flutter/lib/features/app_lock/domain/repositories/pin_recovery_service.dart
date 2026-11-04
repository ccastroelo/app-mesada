import '../../../../core/error/result.dart';

/// Quem fala com o servidor do "esqueci o PIN" (ADR-0023). O servidor só
/// repassa e-mail: o PIN novo nasce no app e não fica guardado lá.
abstract class PinRecoveryService {
  /// Há servidor configurado (`RECOVERY_URL`)? Sem ele o recurso não aparece.
  bool get available;

  /// Registra [email] para este aparelho: o servidor manda uma mensagem de
  /// confirmação (sem PIN) e devolve o token que prova o registro.
  Future<Result<String>> register({
    required String email,
    required String installId,
    required String locale,
  });

  /// Pede ao servidor que mande [pin] (já gerado pelo app) para [email]. Só
  /// dá `Ok` quando o servidor aceitou o envio — e é só então que o app troca
  /// o PIN guardado.
  Future<Result<void>> sendNewPin({
    required String email,
    required String installId,
    required String token,
    required String pin,
    required String locale,
  });
}
