import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/auth_token_provider.dart';

/// The real [AuthTokenProvider] — Firebase ID tokens. Lives in the auth
/// feature's data layer (the only place allowed to touch `firebase_auth`
/// directly) even though the interface it implements is declared in
/// `core/network`.
class FirebaseAuthTokenProvider implements AuthTokenProvider {
  @override
  Future<String?> getToken({bool forceRefresh = false}) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Future.value(null);
    return user.getIdToken(forceRefresh);
  }
}

final firebaseAuthTokenProviderProvider = Provider<AuthTokenProvider>((ref) => FirebaseAuthTokenProvider());
