import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/config/environment.dart';
import 'core/logging/app_logger.dart';
import 'core/storage/app_preferences.dart';

/// TEMPORARY demo bootstrap — Firebase init and Crashlytics are removed
/// until a real Firebase project exists (see NOTES.md and
/// FakeAuthRepository). Once real Firebase credentials are configured,
/// restore `Firebase.initializeApp(...)` + Crashlytics wiring here,
/// alongside swapping FakeAuthRepository back to a real Firebase-backed
/// AuthRepositoryImpl.
Future<void> bootstrap(Environment environment) async {
  Environment.current = environment;

  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      final prefs = await SharedPreferences.getInstance();

      FlutterError.onError = (details) => AppLogger.instance.e(
            details.exceptionAsString(),
            error: details.exception,
            stackTrace: details.stack,
          );

      runApp(ProviderScope(
        overrides: [appPreferencesProvider.overrideWithValue(AppPreferences(prefs))],
        child: const CarVaultApp(),
      ));
    },
    (error, stack) => AppLogger.instance.e('Uncaught zone error', error: error, stackTrace: stack),
  );
}
