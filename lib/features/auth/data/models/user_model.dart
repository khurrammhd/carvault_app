import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/user_entity.dart';

/// Serializable representation of an authenticated user — used for the
/// local "last signed-in session" cache in SecureSessionStorage.
class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final email = json['email'];
    if (id is! String || id.isEmpty) {
      throw const FormatException('UserModel.fromJson: "id" is missing or not a String.');
    }
    if (email is! String) {
      throw const FormatException('UserModel.fromJson: "email" is missing or not a String.');
    }
    return UserModel(
      id: id,
      email: email,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
      };

  Result<UserModel> validate() {
    if (id.isEmpty) return const Failed(ValidationFailure('User id cannot be empty.'));
    if (email.isEmpty || !email.contains('@')) {
      return const Failed(ValidationFailure('User email is missing or invalid.'));
    }
    return Success(this);
  }

  UserEntity toEntity() => UserEntity(id: id, email: email, displayName: displayName, photoUrl: photoUrl);

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(id: entity.id, email: entity.email, displayName: entity.displayName, photoUrl: entity.photoUrl);
  }
}
