import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wrapper around [SharedPreferences] for small, non-sensitive local
/// settings.
class AppPreferences {
  AppPreferences(this._prefs);
  final SharedPreferences _prefs;

  static const _vehicleListFilterKey = 'vehicle_list_filter';

  String? get vehicleListFilter => _prefs.getString(_vehicleListFilterKey);

  Future<void> setVehicleListFilter(String value) {
    return _prefs.setString(_vehicleListFilterKey, value);
  }

  static const _backupEnabledKey = 'backup_enabled';
  static const _backupHourKey = 'backup_hour';
  static const _backupMinuteKey = 'backup_minute';
  static const _connectedDriveAccountEmailKey = 'connected_drive_account_email';
  static const _lastBackupAtIsoKey = 'last_backup_at_iso';
  static const _lastBackupSucceededKey = 'last_backup_succeeded';

  bool get backupEnabled => _prefs.getBool(_backupEnabledKey) ?? false;

  Future<void> setBackupEnabled(bool value) => _prefs.setBool(_backupEnabledKey, value);

  /// Defaults to 2:00 AM — a reasonable time nobody's actively using the
  /// app, matching WhatsApp's own default backup window.
  int get backupHour => _prefs.getInt(_backupHourKey) ?? 2;
  int get backupMinute => _prefs.getInt(_backupMinuteKey) ?? 0;

  Future<void> setBackupTime({required int hour, required int minute}) {
    return Future.wait([_prefs.setInt(_backupHourKey, hour), _prefs.setInt(_backupMinuteKey, minute)]);
  }

  String? get connectedDriveAccountEmail => _prefs.getString(_connectedDriveAccountEmailKey);

  Future<void> setConnectedDriveAccountEmail(String? value) {
    return value == null ? _prefs.remove(_connectedDriveAccountEmailKey) : _prefs.setString(_connectedDriveAccountEmailKey, value);
  }

  DateTime? get lastBackupAt {
    final iso = _prefs.getString(_lastBackupAtIsoKey);
    return iso == null ? null : DateTime.tryParse(iso);
  }

  Future<void> setLastBackupAt(DateTime value) => _prefs.setString(_lastBackupAtIsoKey, value.toIso8601String());

  bool? get lastBackupSucceeded =>
      _prefs.containsKey(_lastBackupSucceededKey) ? _prefs.getBool(_lastBackupSucceededKey) : null;

  Future<void> setLastBackupSucceeded(bool value) => _prefs.setBool(_lastBackupSucceededKey, value);

  Future<void> clear() => _prefs.clear();
}

/// Overridden in `bootstrap.dart` with a real instance once
/// `SharedPreferences.getInstance()` resolves.
final appPreferencesProvider = Provider<AppPreferences>((ref) {
  throw UnimplementedError('appPreferencesProvider must be overridden in bootstrap.dart');
});
