import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/errors/unit.dart';
import '../../../../core/utils/validators.dart';
import '../repositories/auth_repository.dart';

class SendPasswordResetEmail {
  const SendPasswordResetEmail(this._repository);
  final AuthRepository _repository;

  Future<Result<Unit>> call({required String email}) {
    final emailError = Validators.email(email);
    if (emailError != null) return Future.value(Failed(AuthFailure(emailError)));

    return _repository.sendPasswordResetEmail(email: email.trim());
  }
}
