/// Falhas esperadas viram valores, não exceções (arquitetura-alvo §2).
/// Texto de UI fica na presentation; aqui só a categoria da falha.
sealed class Failure {
  const Failure();
}

final class NoConnection extends Failure {
  const NoConnection();
}

final class PermissionDenied extends Failure {
  const PermissionDenied();
}

final class InvalidCredentials extends Failure {
  const InvalidCredentials();
}

final class InvalidEmail extends Failure {
  const InvalidEmail();
}

final class EmailAlreadyInUse extends Failure {
  const EmailAlreadyInUse();
}

final class WeakPassword extends Failure {
  const WeakPassword();
}

/// A pessoa fechou a tela de login: não é erro para mostrar.
final class Cancelled extends Failure {
  const Cancelled();
}

/// Código de convite malformado, inexistente, expirado ou já usado.
final class InvalidInvite extends Failure {
  const InvalidInvite();
}

final class Unexpected extends Failure {
  const Unexpected([this.cause]);

  final Object? cause;
}
