import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/repositories/fake_auth_repository.dart';
import '../../features/auth/domain/entities/user_entity.dart';

/// Bridges the auth feature's repository to a stream [AppRouter]'s
/// redirect logic can read.
final authStateProvider = StreamProvider<UserEntity?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});
