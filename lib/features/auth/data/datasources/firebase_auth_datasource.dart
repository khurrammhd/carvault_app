import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart' show AuthClient;

/// Drive scope requested incrementally for the backup feature — deliberately
/// *not* part of the [GoogleSignIn] instance's default `scopes`, so a plain
/// Google login never shows a Drive consent prompt up front.
const driveFileScope = 'https://www.googleapis.com/auth/drive.file';

/// Raw Firebase Auth + Google Sign-In SDK calls — the only file in this
/// feature allowed to import `firebase_auth`/`google_sign_in` directly.
/// Throws [FirebaseAuthException] on failure; [AuthRepositoryImpl] catches
/// and translates it. Also the sole owner of the single live [GoogleSignIn]
/// instance, reused for both primary login and Drive-only connection (see
/// `signOutGoogleOnly` doc for the accepted tradeoff that implies).
class FirebaseAuthDataSource {
  FirebaseAuthDataSource(this._firebaseAuth, this._googleSignIn);

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<User> signInWithEmail({required String email, required String password}) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    return credential.user!;
  }

  Future<User> registerWithEmail({required String email, required String password}) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    return credential.user!;
  }

  /// Returns `null` if the user cancels the Google account picker — a
  /// normal outcome, not an error. The returned [UserCredential] (rather
  /// than just its `.user`) lets callers read `additionalUserInfo.isNewUser`
  /// to tell a fresh sign-up from a returning login.
  Future<UserCredential?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _firebaseAuth.signInWithCredential(credential);
  }

  Future<void> sendPasswordResetEmail({required String email}) {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() {
    return Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
  }

  /// The currently connected Google account, if any — used by the backup
  /// feature to show "Connected as ..." without a fresh sign-in round trip.
  GoogleSignInAccount? get currentGoogleAccount => _googleSignIn.currentUser;

  /// Rehydrates `currentGoogleAccount` from the native side's cached
  /// session without any user interaction. Required in two cases: a fresh
  /// `GoogleSignIn` instance (e.g. the WorkManager background isolate,
  /// which shares nothing with the running app) has a `null` `currentUser`
  /// until this is called at least once; returns `null` if no session can
  /// be silently restored (the user must reconnect interactively).
  Future<GoogleSignInAccount?> signInSilently() => _googleSignIn.signInSilently();

  /// A `googleapis`-compatible authenticated client for the currently
  /// signed-in Google account, built from `extension_google_sign_in_as_googleapis_auth`.
  /// Returns `null` if no account is signed in on this `GoogleSignIn`
  /// instance yet — callers must ensure `currentGoogleAccount` is populated
  /// (via `signInSilently`/`signInForDriveOnly`/`requestDriveScope`) first.
  Future<AuthClient?> authenticatedDriveClient() => _googleSignIn.authenticatedClient();

  /// Incremental consent path for a user who is *already* signed in with
  /// Google (their primary login never requested Drive access up front).
  /// Returns `true` once `drive.file` is granted, `false` if the user
  /// declines the extra consent screen.
  Future<bool> requestDriveScope() => _googleSignIn.requestScopes([driveFileScope]);

  /// Drive-only connection path for an email/password user with no Google
  /// account attached at all. Deliberately never touches `_firebaseAuth` —
  /// this must not change the user's primary sign-in identity/provider.
  /// Returns `null` if the account picker is cancelled or the Drive consent
  /// screen is declined.
  Future<GoogleSignInAccount?> signInForDriveOnly() async {
    final account = await _googleSignIn.signIn();
    if (account == null) return null;
    final granted = await _googleSignIn.requestScopes([driveFileScope]);
    return granted ? account : null;
  }

  /// Disconnects the Drive-only Google session. Shares the same
  /// [GoogleSignIn] instance as primary login, so this is also called by
  /// `signOut()` — meaning an email/password user's Drive connection is
  /// cleared on every app logout and must be reconnected. Accepted
  /// deliberately: running two live `GoogleSignIn` instances concurrently is
  /// unverified territory on Android and a bigger risk than this papercut.
  Future<void> signOutGoogleOnly() => _googleSignIn.signOut();
}

final firebaseAuthDataSourceProvider = Provider<FirebaseAuthDataSource>((ref) {
  return FirebaseAuthDataSource(FirebaseAuth.instance, GoogleSignIn());
});
