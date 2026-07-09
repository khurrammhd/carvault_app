import '../repositories/drive_auth_repository.dart';

class DisconnectDrive {
  const DisconnectDrive(this._repository);
  final DriveAuthRepository _repository;

  Future<void> call() => _repository.disconnect();
}
