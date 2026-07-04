/// An authenticated user — the domain layer's plain representation.
class UserEntity {
  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;

  @override
  bool operator ==(Object other) => other is UserEntity && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
