import '../../../../core/errors/result.dart';
import '../repositories/drive_auth_repository.dart';

class ConnectDrive {
  const ConnectDrive(this._repository);
  final DriveAuthRepository _repository;

  Future<Result<String>> call() => _repository.connect();
}
