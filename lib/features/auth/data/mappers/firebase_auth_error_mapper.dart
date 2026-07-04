import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/failure.dart';

/// Translates Firebase's error codes into user-facing copy. Firebase's own
/// `e.message` is written for developers, not end users, so every code the
/// app can realistically hit is mapped explicitly here.
AuthFailure mapFirebaseAuthException(FirebaseAuthException e) {
  final message = switch (e.code) {
    'invalid-email' => 'That email address looks invalid.',
    'user-disabled' => 'This account has been disabled.',
    'user-not-found' => 'No account found with that email.',
    'wrong-password' || 'invalid-credential' => 'Incorrect email or password.',
    'email-already-in-use' => 'An account already exists with that email.',
    'weak-password' => 'Choose a stronger password (at least 8 characters).',
    'too-many-requests' => 'Too many attempts. Please wait a moment and try again.',
    'network-request-failed' => 'No internet connection. Please check your network and try again.',
    _ => 'Something went wrong. Please try again.',
  };
  return AuthFailure(message);
}
