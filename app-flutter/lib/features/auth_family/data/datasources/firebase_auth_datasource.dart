import 'package:firebase_auth/firebase_auth.dart';

/// Único ponto que fala com o SDK do Firebase Auth.
class FirebaseAuthDataSource {
  FirebaseAuthDataSource(this._auth);

  final FirebaseAuth _auth;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<void> signInWithEmail(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<void> signUpWithEmail(String email, String password) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  /// Fluxo OAuth do Firebase (navegador do sistema); não exige SHA-1 no Android.
  Future<void> signInWithGoogle() =>
      _auth.signInWithProvider(GoogleAuthProvider());

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<void> signOut() => _auth.signOut();
}
