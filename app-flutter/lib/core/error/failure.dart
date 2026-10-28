/// Falhas esperadas viram valores, não exceções (arquitetura-alvo §2).
/// Texto de UI fica na presentation; aqui só a categoria da falha.
sealed class Failure {
  const Failure();
}

final class NoConnection extends Failure {
  const NoConnection();
}

final class Unexpected extends Failure {
  const Unexpected([this.cause]);

  final Object? cause;
}
