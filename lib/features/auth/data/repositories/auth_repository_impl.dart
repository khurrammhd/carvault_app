import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/errors/unit.dart';
import '../../../../core/storage/secure_session_storage.dart';
import '../../domain/entities/google_sign_in_result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';
import '../mappers/firebase_auth_error_mapper.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource, this._sessionStorage);

  final FirebaseAuthDataSource _dataSource;
  final SecureSessionStorage _sessionStorage;

  @override
  Stream<UserEntity?> get authStateChanges =>
      _dataSource.authStateChanges().map((user) => user == null ? null : UserModel.fromFirebaseUser(user).toEntity());

  @override
  UserEntity? get currentUser {
    final user = _dataSource.currentUser;
    return user == null ? null : UserModel.fromFirebaseUser(user).toEntity();
  }

  Future<Result<UserEntity>> _authenticate(Future<User> Function() action) async {
    try {
      final entity = UserModel.fromFirebaseUser(await action()).toEntity();
      await _sessionStorage.saveLastSession(UserModel.fromEntity(entity));
      return Success(entity);
    } on FirebaseAuthException catch (e) {
      return Failed(mapFirebaseAuthException(e));
    } catch (e) {
      return Failed(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> loginWithEmail({required String email, required String password}) {
    return _authenticate(() => _dataSource.signInWithEmail(email: email, password: password));
  }

  @override
  Future<Result<UserEntity>> registerWithEmail({required String email, required String password}) {
    return _authenticate(() => _dataSource.registerWithEmail(email: email, password: password));
  }

  @override
  Future<Result<GoogleSignInResult?>> loginWithGoogle() async {
    try {
      final credential = await _dataSource.signInWithGoogle();
      final user = credential?.user;
      if (user == null) return const Success(null); // cancelled — not a failure

      final entity = UserModel.fromFirebaseUser(user).toEntity();
      await _sessionStorage.saveLastSession(UserModel.fromEntity(entity));
      return Success(GoogleSignInResult(user: entity, isNewUser: credential!.additionalUserInfo?.isNewUser ?? false));
    } on FirebaseAuthException catch (e) {
      return Failed(mapFirebaseAuthException(e));
    } catch (e) {
      return Failed(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<Unit>> sendPasswordResetEmail({required String email}) async {
    try {
      await _dataSource.sendPasswordResetEmail(email: email);
      return const Success(Unit.value);
    } on FirebaseAuthException catch (e) {
      return Failed(mapFirebaseAuthException(e));
    } catch (e) {
      return Failed(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<void> logout() async {
    await _dataSource.signOut();
    await _sessionStorage.clear();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(firebaseAuthDataSourceProvider),
    ref.watch(secureSessionStorageProvider),
  );
});
