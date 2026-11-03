import '../../../../core/error/result.dart';
import '../entities/entry.dart';

/// Lançamentos da família.
///
/// Lembrete (ADR-0013): par filho × regra sem documento = quantidade 0 e regra
/// ativada. O lançamento nasce no primeiro toque em +, ou ao desativar a regra
/// para o filho.
abstract class LedgerRepository {
  Stream<List<Entry>> watchEntries(String familyId);

  /// +1 na quantidade do par filho × regra.
  Future<Result<void>> increment(
    String familyId, {
    required String childId,
    required String ruleId,
  });

  /// −1 na quantidade, com piso 0 (`imLanVC.m:119`).
  Future<Result<void>> decrement(
    String familyId, {
    required String childId,
    required String ruleId,
  });

  /// Ativa ou desativa a regra para o filho. A quantidade é **preservada**,
  /// só fica fora do saldo (ADR-0008).
  Future<Result<void>> setEnabled(
    String familyId, {
    required String childId,
    required String ruleId,
    required bool enabled,
  });

  /// Zera as quantidades de um filho, ou de **todos** se [childId] for nulo.
  /// Não mexe na mesada nem no `enabled`.
  Future<Result<void>> zero(String familyId, {String? childId});

  /// Repõe as quantidades de [entries] — o "Desfazer" do zerar. Quem chama
  /// guarda o que havia antes (a tela já tem a lista).
  Future<Result<void>> restore(String familyId, Iterable<Entry> entries);
}
