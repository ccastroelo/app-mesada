import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/core/error/failure.dart';
import 'package:mesada/core/firebase/firebase_failures.dart';

void main() {
  Failure auth(String code) =>
      failureFromFirebase(FirebaseAuthException(code: code));
  Failure store(String code) => failureFromFirebase(
    FirebaseException(plugin: 'cloud_firestore', code: code),
  );

  test('erros de login viram falhas de domínio', () {
    expect(auth('wrong-password'), isA<InvalidCredentials>());
    expect(auth('user-not-found'), isA<InvalidCredentials>());
    expect(auth('invalid-credential'), isA<InvalidCredentials>());
    expect(auth('invalid-email'), isA<InvalidEmail>());
    expect(auth('email-already-in-use'), isA<EmailAlreadyInUse>());
    expect(auth('weak-password'), isA<WeakPassword>());
    expect(auth('network-request-failed'), isA<NoConnection>());
    expect(auth('web-context-canceled'), isA<Cancelled>());
    expect(auth('qualquer-outro'), isA<Unexpected>());
  });

  test('erros do Firestore viram falhas de domínio', () {
    expect(store('unavailable'), isA<NoConnection>());
    expect(store('deadline-exceeded'), isA<NoConnection>());
    expect(store('permission-denied'), isA<PermissionDenied>());
    expect(store('not-found'), isA<Unexpected>());
  });

  test('exceção desconhecida vira Unexpected com a causa', () {
    final failure = failureFromFirebase(StateError('x'));
    expect(failure, isA<Unexpected>());
    expect((failure as Unexpected).cause, isA<StateError>());
  });
}
