import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../../../../core/storage/app_preferences.dart';
import '../../domain/usecases/backup_usecases.dart';
import 'backup_workmanager_service.dart';

/// Entry point WorkManager invokes from a cold background isolate that
/// shares nothing with the running app (if the app is even open at all).
/// Firebase, SharedPreferences, and the whole Riverpod provider graph must
/// be reinitialized from scratch here — this is the single highest-risk
/// piece of the backup feature (see PROJECT_CONTEXT.md §5 for the
/// reasoning) and should be exercised on-device before trusting it.
@pragma('vm:entry-point')
void backupCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await Firebase.initializeApp();
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [appPreferencesProvider.overrideWithValue(AppPreferences(prefs))],
      );

      try {
        final appPreferences = container.read(appPreferencesProvider);
        if (appPreferences.backupEnabled) {
          await container.read(performBackupProvider)();
          // Reschedule tomorrow's run regardless of success/failure — a
          // transient failure (e.g. no network at 2am) shouldn't silently
          // stop every future attempt.
          await container.read(backupWorkmanagerServiceProvider).scheduleNextRun(
                hour: appPreferences.backupHour,
                minute: appPreferences.backupMinute,
              );
        }
      } finally {
        container.dispose();
      }

      return Future.value(true);
    } catch (_) {
      // Nothing to surface an error to in a background isolate — WorkManager
      // applies its own retry/backoff to a `false` result.
      return Future.value(false);
    }
  });
}
