import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/utils/validators.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginWithEmail {
  const LoginWithEmail(this._repository);
  final AuthRepository _repository;

  Future<Result<UserEntity>> call({required String email, required String password}) {
    final emailError = Validators.email(email);
    if (emailError != null) return Future.value(Failed(AuthFailure(emailError)));

    final passwordError = Validators.password(password);
    if (passwordError != null) return Future.value(Failed(AuthFailure(passwordError)));

    return _repository.loginWithEmail(email: email.trim(), password: password);
  }
}
