/// Abstraction over "how do I get a bearer token for outgoing requests."
/// Kept separate from the auth repository — a token is a networking-layer
/// concept, not a domain concept. The concrete (Firebase-backed)
/// implementation and its provider binding live in
/// features/auth/data/services/firebase_auth_token_provider.dart — the
/// only place allowed to import `firebase_auth` directly.
abstract class AuthTokenProvider {
  Future<String?> getToken({bool forceRefresh = false});
}
