import 'package:firebase_auth/firebase_auth.dart';

import '../error/failure.dart';

/// Converte exceção do SDK do Firebase em [Failure]. Só a camada `data` usa.
Failure failureFromFirebase(Object error) {
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' ||
      'invalid-login-credentials' => const InvalidCredentials(),
      'invalid-email' => const InvalidEmail(),
      'email-already-in-use' => const EmailAlreadyInUse(),
      'weak-password' => const WeakPassword(),
      'network-request-failed' => const NoConnection(),
      'canceled' ||
      'cancelled' ||
      'web-context-canceled' ||
      'popup-closed-by-user' => const Cancelled(),
      _ => Unexpected(error),
    };
  }
  if (error is FirebaseException) {
    return switch (error.code) {
      'unavailable' || 'deadline-exceeded' => const NoConnection(),
      'permission-denied' => const PermissionDenied(),
      _ => Unexpected(error),
    };
  }
  return Unexpected(error);
}
