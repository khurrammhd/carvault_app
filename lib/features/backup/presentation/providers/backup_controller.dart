import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/errors/unit.dart';
import '../../data/repositories/backup_repository_impl.dart';
import '../../data/services/backup_workmanager_service.dart';
import '../../domain/entities/backup_settings_entity.dart';
import '../../domain/usecases/backup_usecases.dart';

/// Mirrors [AuthController]'s `_run<T>` pattern: every action goes through
/// a shared `AsyncValue<void>` state so the Settings screen can show a
/// single consistent loading/error treatment. `settings` is a plain
/// synchronous read (not a `Stream`) — cheap enough that screens can just
/// re-read it after every action completes.
class BackupController extends StateNotifier<AsyncValue<void>> {
  BackupController(this._ref) : super(const AsyncData(null));

  final Ref _ref;

  BackupSettingsEntity get settings => _ref.read(backupRepositoryProvider).readSettings();

  Future<void> toggleEnabled(bool enabled) => _run(() async {
        final current = settings;
        await _ref.read(updateBackupScheduleProvider)(enabled: enabled, hour: current.hour, minute: current.minute);
        final workmanager = _ref.read(backupWorkmanagerServiceProvider);
        if (enabled) {
          await workmanager.scheduleNextRun(hour: current.hour, minute: current.minute);
        } else {
          await workmanager.cancel();
        }
        return const Success(Unit.value);
      });

  Future<void> setTime(TimeOfDay time) => _run(() async {
        final current = settings;
        await _ref.read(updateBackupScheduleProvider)(enabled: current.enabled, hour: time.hour, minute: time.minute);
        if (current.enabled) {
          await _ref.read(backupWorkmanagerServiceProvider).scheduleNextRun(hour: time.hour, minute: time.minute);
        }
        return const Success(Unit.value);
      });

  Future<void> backupNow() => _run(() => _ref.read(performBackupProvider)());

  Future<void> restoreNow() => _run(() => _ref.read(restoreLatestBackupProvider)());

  Future<void> connectDrive() => _run(() => _ref.read(connectDriveProvider)());

  Future<void> disconnectDrive() => _run(() async {
        await _ref.read(disconnectDriveProvider)();
        return const Success(Unit.value);
      });

  Future<void> _run<T>(Future<Result<T>> Function() action) async {
    state = const AsyncLoading();
    final result = await action();
    state = result.when(
      success: (_) => const AsyncData(null),
      failure: (f) => AsyncError<void>(f, StackTrace.current),
    );
  }
}

final backupControllerProvider = StateNotifierProvider<BackupController, AsyncValue<void>>((ref) {
  return BackupController(ref);
});
