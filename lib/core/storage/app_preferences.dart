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

  Future<void> clear() => _prefs.clear();
}

/// Overridden in `bootstrap.dart` with a real instance once
/// `SharedPreferences.getInstance()` resolves.
final appPreferencesProvider = Provider<AppPreferences>((ref) {
  throw UnimplementedError('appPreferencesProvider must be overridden in bootstrap.dart');
});
