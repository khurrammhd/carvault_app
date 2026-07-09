import '../repositories/backup_repository.dart';

class UpdateBackupSchedule {
  const UpdateBackupSchedule(this._repository);
  final BackupRepository _repository;

  Future<void> call({required bool enabled, required int hour, required int minute}) {
    return _repository.updateSchedule(enabled: enabled, hour: hour, minute: minute);
  }
}
