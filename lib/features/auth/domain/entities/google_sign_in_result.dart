import 'user_entity.dart';

/// Result of a Google sign-in attempt, carrying Firebase's `isNewUser`
/// signal up through the domain boundary — used to show the one-time
/// "back up to Google Drive?" prompt only on fresh sign-ups, not every
/// returning login.
class GoogleSignInResult {
  const GoogleSignInResult({required this.user, required this.isNewUser});

  final UserEntity user;
  final bool isNewUser;
}
