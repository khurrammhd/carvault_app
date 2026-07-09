import '../../../../core/errors/result.dart';
import '../../../../core/errors/unit.dart';
import '../entities/google_sign_in_result.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;
  UserEntity? get currentUser;

  Future<Result<UserEntity>> loginWithEmail({required String email, required String password});

  Future<Result<UserEntity>> registerWithEmail({required String email, required String password});

  /// A `Success(null)` means the user cancelled the picker — not a failure.
  Future<Result<GoogleSignInResult?>> loginWithGoogle();

  Future<Result<Unit>> sendPasswordResetEmail({required String email});

  Future<void> logout();
}
