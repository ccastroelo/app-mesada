/// Onde o **início do teste** fica guardado fora dos arquivos do app, para
/// sobreviver a reinstalar (ADR-0024).
///
/// É só uma data, nunca um "pagou". A compra e a assinatura continuam sendo
/// direitos que a loja guarda e confirma (ADR-0021).
abstract class SecureTrialStore {
  /// O início do teste guardado, ou nulo quando não há nada guardado **ou**
  /// não deu para ler. Nulo é "não sei": quem lê trata como primeiro uso.
  Future<DateTime?> read();

  /// Guarda o início do teste. Falha de gravação é engolida: o app não pode
  /// deixar de abrir porque o cofre do sistema recusou.
  Future<void> save(DateTime since);
}
