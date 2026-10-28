import '../entities/entry.dart';

/// Lançamentos da família. Nesta etapa só leitura (para o saldo); as escritas
/// (+/−, ativar/desativar, zerar) chegam com a tela do filho.
///
/// Lembrete (ADR-0013): par filho × regra sem documento = quantidade 0 e regra
/// ativada.
abstract class LedgerRepository {
  Stream<List<Entry>> watchEntries(String familyId);
}
