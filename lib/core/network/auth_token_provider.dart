import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Abstraction over "how do I get a bearer token for outgoing requests."
/// Kept separate from the auth repository — a token is a networking-layer
/// concept, not a domain concept.
abstract class AuthTokenProvider {
  Future<String?> getToken({bool forceRefresh = false});
}

/// TEMPORARY stand-in used because no real backend/Firebase project
/// exists yet. Swap for a Firebase-backed implementation once real auth
/// is wired up — nothing that depends on [AuthTokenProvider] needs to
/// change.
class FakeAuthTokenProvider implements AuthTokenProvider {
  @override
  Future<String?> getToken({bool forceRefresh = false}) async => null;
}

final authTokenProviderProvider = Provider<AuthTokenProvider>((ref) => FakeAuthTokenProvider());
