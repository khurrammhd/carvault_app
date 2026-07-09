import '../../../../core/errors/result.dart';
import '../../../../core/errors/unit.dart';
import '../repositories/backup_repository.dart';

class RestoreLatestBackup {
  const RestoreLatestBackup(this._repository);
  final BackupRepository _repository;

  Future<Result<Unit>> call() => _repository.restoreLatestBackup();
}
