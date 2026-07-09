import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'app/app.dart';
import 'core/config/environment.dart';
import 'core/logging/app_logger.dart';
import 'core/storage/app_preferences.dart';
import 'features/backup/data/services/backup_callback_dispatcher.dart';
import 'features/backup/data/services/backup_workmanager_service.dart';

Future<void> bootstrap(Environment environment) async {
  Environment.current = environment;

  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // No explicit FirebaseOptions passed — this app is Android-only, and
      // on Android the native SDK reads its config from
      // android/app/google-services.json (processed by the Google
      // services Gradle plugin) automatically. Explicit FirebaseOptions
      // only become necessary if/when web or desktop support is added.
      await Firebase.initializeApp();

      final prefs = await SharedPreferences.getInstance();
      final appPreferences = AppPreferences(prefs);

      await Workmanager().initialize(backupCallbackDispatcher, isInDebugMode: !environment.isProduction);
      // Defensively re-schedule on every app start: covers a scheduled
      // task lost to a force-stop that's since been cleared by the user
      // simply reopening the app — WorkManager gives no other signal that
      // this happened.
      if (appPreferences.backupEnabled) {
        const workmanagerService = BackupWorkmanagerService();
        await workmanagerService.scheduleNextRun(hour: appPreferences.backupHour, minute: appPreferences.backupMinute);
      }

      if (environment.reportCrashes) {
        FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
        PlatformDispatcher.instance.onError = (error, stack) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          return true;
        };
      } else {
        FlutterError.onError = (details) => AppLogger.instance.e(
              details.exceptionAsString(),
              error: details.exception,
              stackTrace: details.stack,
            );
      }

      runApp(ProviderScope(
        overrides: [appPreferencesProvider.overrideWithValue(appPreferences)],
        child: const CarVaultApp(),
      ));
    },
    (error, stack) {
      if (environment.reportCrashes) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      } else {
        AppLogger.instance.e('Uncaught zone error', error: error, stackTrace: stack);
      }
    },
  );
}
