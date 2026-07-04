import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Raw Firebase Auth + Google Sign-In SDK calls — the only file in this
/// feature allowed to import `firebase_auth`/`google_sign_in` directly.
/// Throws [FirebaseAuthException] on failure; [AuthRepositoryImpl] catches
/// and translates it.
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
  /// normal outcome, not an error.
  Future<User?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    return userCredential.user;
  }

  Future<void> sendPasswordResetEmail({required String email}) {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() {
    return Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
  }
}

final firebaseAuthDataSourceProvider = Provider<FirebaseAuthDataSource>((ref) {
  return FirebaseAuthDataSource(FirebaseAuth.instance, GoogleSignIn());
});
