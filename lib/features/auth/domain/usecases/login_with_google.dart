import '../../../../core/errors/result.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginWithGoogle {
  const LoginWithGoogle(this._repository);
  final AuthRepository _repository;

  Future<Result<UserEntity?>> call() => _repository.loginWithGoogle();
}
