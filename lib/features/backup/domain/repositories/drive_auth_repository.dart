import '../../../../core/errors/result.dart';

/// Owns connecting/disconnecting the Google account used for Drive backups
/// — separate from [AuthRepository], since a user's primary sign-in
/// identity (email/password vs. Google) is independent of whether Drive
/// access has been granted.
abstract class DriveAuthRepository {
  String? get currentAccountEmail;

  /// Dispatches to incremental consent (already a Google user) or a
  /// separate Drive-only sign-in (email/password user), based on the
  /// signed-in user's `isGoogleUser`. Returns the connected account's email.
  Future<Result<String>> connect();

  Future<void> disconnect();
}
