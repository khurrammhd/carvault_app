import '../../../../core/errors/result.dart';
import '../../../../core/errors/unit.dart';
import '../repositories/backup_repository.dart';

class PerformBackup {
  const PerformBackup(this._repository);
  final BackupRepository _repository;

  Future<Result<Unit>> call() => _repository.performBackup();
}
