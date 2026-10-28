import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../error/failure.dart';
import '../theme/tokens.dart';

/// Texto de tela para uma [Failure]; null quando não há nada a mostrar
/// (a pessoa só cancelou).
String? failureMessage(AppLocalizations l10n, Failure failure) {
  return switch (failure) {
    Cancelled() => null,
    InvalidCredentials() => l10n.errorInvalidCredentials,
    InvalidEmail() => l10n.errorInvalidEmail,
    EmailAlreadyInUse() => l10n.errorEmailInUse,
    WeakPassword() => l10n.errorWeakPassword,
    NoConnection() => l10n.errorNoConnection,
    InvalidInvite() => l10n.errorInvalidInvite,
    PermissionDenied() => l10n.errorPermissionDenied,
    Unexpected() => l10n.errorUnexpected,
  };
}

/// Erro em texto abaixo do campo ou do botão, nunca só em snackbar (design.md).
class FailureText extends StatelessWidget {
  const FailureText(this.failure, {super.key});

  final Failure? failure;

  @override
  Widget build(BuildContext context) {
    final failure = this.failure;
    if (failure == null) return const SizedBox.shrink();
    final message = failureMessage(AppLocalizations.of(context), failure);
    if (message == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: Space.sm),
      child: Semantics(
        liveRegion: true,
        child: Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }
}
