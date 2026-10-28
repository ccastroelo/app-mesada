import '../../../../core/error/result.dart';
import '../../../../core/firebase/firebase_failures.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);

  final FirebaseAuthDataSource _remote;

  @override
  Stream<AppUser?> authStateChanges() {
    return _remote.authStateChanges().map(
      (user) =>
          user == null ? null : AppUser(uid: user.uid, email: user.email ?? ''),
    );
  }

  @override
  Future<Result<void>> signInWithEmail(String email, String password) =>
      _guard(() => _remote.signInWithEmail(email, password));

  @override
  Future<Result<void>> signUpWithEmail(String email, String password) =>
      _guard(() => _remote.signUpWithEmail(email, password));

  @override
  Future<Result<void>> signInWithGoogle() => _guard(_remote.signInWithGoogle);

  @override
  Future<Result<void>> sendPasswordReset(String email) =>
      _guard(() => _remote.sendPasswordReset(email));

  @override
  Future<Result<void>> signOut() => _guard(_remote.signOut);

  Future<Result<void>> _guard(Future<void> Function() action) async {
    try {
      await action();
      return const Ok(null);
    } catch (error) {
      return Err(failureFromFirebase(error));
    }
  }
}
