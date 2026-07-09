import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../../auth/data/datasources/firebase_auth_datasource.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/repositories/drive_auth_repository.dart';

class DriveAuthRepositoryImpl implements DriveAuthRepository {
  DriveAuthRepositoryImpl(this._authDataSource, this._authRepository, this._prefs);

  final FirebaseAuthDataSource _authDataSource;
  final AuthRepository _authRepository;
  final AppPreferences _prefs;

  @override
  String? get currentAccountEmail => _prefs.connectedDriveAccountEmail;

  @override
  Future<Result<String>> connect() async {
    try {
      final user = _authRepository.currentUser;
      if (user == null) return const Failed(AuthFailure('Not signed in.'));

      final String? email;
      if (user.isGoogleUser) {
        final granted = await _authDataSource.requestDriveScope();
        email = granted ? (_authDataSource.currentGoogleAccount?.email ?? user.email) : null;
      } else {
        final account = await _authDataSource.signInForDriveOnly();
        email = account?.email;
      }

      if (email == null) return const Failed(AuthFailure('Google Drive access was not granted.'));

      await _prefs.setConnectedDriveAccountEmail(email);
      return Success(email);
    } catch (e) {
      return Failed(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<void> disconnect() async {
    await _authDataSource.signOutGoogleOnly();
    await _prefs.setConnectedDriveAccountEmail(null);
  }
}

final driveAuthRepositoryProvider = Provider<DriveAuthRepository>((ref) {
  return DriveAuthRepositoryImpl(
    ref.watch(firebaseAuthDataSourceProvider),
    ref.watch(authRepositoryProvider),
    ref.watch(appPreferencesProvider),
  );
});
