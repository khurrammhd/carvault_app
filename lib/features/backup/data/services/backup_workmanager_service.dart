import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

const backupTaskUniqueName = 'carvault-daily-backup';
const backupTaskName = 'carvault-daily-backup-task';

/// Schedules the daily backup as a self-rescheduling one-off WorkManager
/// task — deliberately *not* `registerPeriodicTask`. WorkManager's periodic
/// tasks can't pin to a specific wall-clock time (only "every N hours from
/// first registration"), which would drift from the user's chosen time
/// faster than reschedule-on-completion does. `existingWorkPolicy.replace`
/// means re-scheduling (e.g. after the user changes the time) never stacks
/// duplicate pending runs.
class BackupWorkmanagerService {
  const BackupWorkmanagerService();

  Future<void> scheduleNextRun({required int hour, required int minute}) {
    return Workmanager().registerOneOffTask(
      backupTaskUniqueName,
      backupTaskName,
      initialDelay: _delayUntilNext(hour: hour, minute: minute),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  Future<void> cancel() => Workmanager().cancelByUniqueName(backupTaskUniqueName);

  Duration _delayUntilNext({required int hour, required int minute}) {
    final now = DateTime.now();
    var next = DateTime(now.year, now.month, now.day, hour, minute);
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
    return next.difference(now);
  }
}

final backupWorkmanagerServiceProvider = Provider<BackupWorkmanagerService>((ref) {
  return const BackupWorkmanagerService();
});
