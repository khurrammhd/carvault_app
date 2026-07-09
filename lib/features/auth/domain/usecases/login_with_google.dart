import '../../../../core/errors/result.dart';
import '../entities/google_sign_in_result.dart';
import '../repositories/auth_repository.dart';

class LoginWithGoogle {
  const LoginWithGoogle(this._repository);
  final AuthRepository _repository;

  Future<Result<GoogleSignInResult?>> call() => _repository.loginWithGoogle();
}
