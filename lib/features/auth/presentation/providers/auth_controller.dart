import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../domain/usecases/auth_providers.dart';

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this._ref) : super(const AsyncData(null));

  final Ref _ref;

  Future<void> loginWithEmail({required String email, required String password}) =>
      _run(() => _ref.read(loginWithEmailProvider)(email: email, password: password));

  Future<void> register({required String email, required String password}) =>
      _run(() => _ref.read(registerWithEmailProvider)(email: email, password: password));

  Future<void> loginWithGoogle() => _run(() => _ref.read(loginWithGoogleProvider)());

  Future<void> sendPasswordResetEmail({required String email}) =>
      _run(() => _ref.read(sendPasswordResetEmailProvider)(email: email));

  Future<void> logout() async {
    state = const AsyncLoading();
    await _ref.read(logoutProvider)();
    state = const AsyncData(null);
  }

  // Generic over T (the Result's success value) so `result` keeps a real
  // static type. A previous version typed `action` as
  // `Future<dynamic> Function()`, which meant `result.when(...)` — an
  // *extension* method — couldn't be resolved: extension methods are
  // matched by static type, and `dynamic` has none, so it failed at
  // runtime with NoSuchMethodError instead of a compile error. That broke
  // every auth action (not just Google), since they all go through this
  // method.
  Future<void> _run<T>(Future<Result<T>> Function() action) async {
    state = const AsyncLoading();
    final result = await action();
    state = result.when(
      success: (_) => const AsyncData(null),
      failure: (f) => AsyncError<void>(f, StackTrace.current),
    );
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref);
});
