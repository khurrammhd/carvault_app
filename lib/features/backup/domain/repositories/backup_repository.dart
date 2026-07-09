import '../../../../core/errors/result.dart';
import '../../../../core/errors/unit.dart';
import '../entities/backup_settings_entity.dart';

abstract class BackupRepository {
  BackupSettingsEntity readSettings();

  Future<void> updateSchedule({required bool enabled, required int hour, required int minute});

  Future<Result<Unit>> performBackup();

  Future<Result<Unit>> restoreLatestBackup();
}
