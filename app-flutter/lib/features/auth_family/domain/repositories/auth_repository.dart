import '../../../../core/error/result.dart';
import '../entities/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();

  Future<Result<void>> signInWithEmail(String email, String password);

  Future<Result<void>> signUpWithEmail(String email, String password);

  Future<Result<void>> signInWithGoogle();

  Future<Result<void>> sendPasswordReset(String email);

  Future<Result<void>> signOut();
}
