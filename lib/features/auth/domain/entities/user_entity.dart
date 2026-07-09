/// An authenticated user — the domain layer's plain representation.
class UserEntity {
  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.isGoogleUser = false,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;

  /// Whether this account's primary sign-in provider is Google. Determines
  /// how the backup feature connects Drive access: an incremental scope
  /// request on this same account vs. a separate Drive-only Google sign-in.
  final bool isGoogleUser;

  @override
  bool operator ==(Object other) => other is UserEntity && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
