import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/backup_repository_impl.dart';
import '../../data/repositories/drive_auth_repository_impl.dart';
import 'connect_drive.dart';
import 'disconnect_drive.dart';
import 'perform_backup.dart';
import 'restore_latest_backup.dart';
import 'update_backup_schedule.dart';

final performBackupProvider = Provider((ref) => PerformBackup(ref.watch(backupRepositoryProvider)));
final restoreLatestBackupProvider = Provider((ref) => RestoreLatestBackup(ref.watch(backupRepositoryProvider)));
final updateBackupScheduleProvider = Provider((ref) => UpdateBackupSchedule(ref.watch(backupRepositoryProvider)));
final connectDriveProvider = Provider((ref) => ConnectDrive(ref.watch(driveAuthRepositoryProvider)));
final disconnectDriveProvider = Provider((ref) => DisconnectDrive(ref.watch(driveAuthRepositoryProvider)));
