import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/data/models/user_model.dart';
import '../errors/result.dart';

/// Persists a small, non-token session marker (last signed-in user's id +
/// email) in the platform Keychain/Keystore. This is NOT where the real
/// auth session lives — that's the auth provider's job — this cache exists
/// only for instant "who was last signed in" reads.
class SecureSessionStorage {
  SecureSessionStorage(this._storage);
  final FlutterSecureStorage _storage;

  static const _lastSessionKey = 'last_session';

  Future<void> saveLastSession(UserModel user) async {
    final result = user.validate();
    result.when(success: (_) {}, failure: (f) => throw ArgumentError(f.message));
    await _storage.write(key: _lastSessionKey, value: jsonEncode(user.toJson()));
  }

  Future<UserModel?> readLastSession() async {
    final raw = await _storage.read(key: _lastSessionKey);
    if (raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on FormatException {
      return null;
    }
  }

  Future<void> clear() => _storage.delete(key: _lastSessionKey);
}

final secureSessionStorageProvider = Provider<SecureSessionStorage>((ref) {
  return SecureSessionStorage(const FlutterSecureStorage());
});
