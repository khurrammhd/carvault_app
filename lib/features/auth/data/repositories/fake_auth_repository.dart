import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/errors/unit.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

/// TEMPORARY stand-in for a Firebase-backed [AuthRepository], used until a
/// real Firebase project exists. Accepts any email/password combination
/// and "logs in" immediately, entirely in memory — nothing here is
/// persisted or secure.
///
/// Swap this provider's binding back to a real Firebase-backed
/// AuthRepositoryImpl once real Firebase credentials are configured —
/// nothing above this file (use cases, controllers, screens) needs to
/// change, since they only depend on the [AuthRepository] interface. See
/// NOTES.md for the exact steps.
class FakeAuthRepository implements AuthRepository {
  final _controller = StreamController<UserEntity?>.broadcast();
  UserEntity? _currentUser;

  @override
  Stream<UserEntity?> get authStateChanges => _controller.stream;

  @override
  UserEntity? get currentUser => _currentUser;

  Future<Result<UserEntity>> _fakeSignIn(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final user = UserEntity(id: 'demo-${email.hashCode}', email: email);
    _currentUser = user;
    _controller.add(user);
    return Success(user);
  }

  @override
  Future<Result<UserEntity>> loginWithEmail({required String email, required String password}) {
    return _fakeSignIn(email);
  }

  @override
  Future<Result<UserEntity>> registerWithEmail({required String email, required String password}) {
    return _fakeSignIn(email);
  }

  @override
  Future<Result<UserEntity?>> loginWithGoogle() async {
    final result = await _fakeSignIn('demo.user@carvault.app');
    return result.when(success: (u) => Success(u), failure: (f) => Failed(f));
  }

  @override
  Future<Result<Unit>> sendPasswordResetEmail({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const Success(Unit.value);
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    _controller.add(null);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) => FakeAuthRepository());
