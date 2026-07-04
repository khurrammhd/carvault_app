import 'package:carvault/core/errors/failure.dart';
import 'package:carvault/core/errors/result.dart';
import 'package:flutter_test/flutter_test.dart';

// Regression test for a real bug: AuthController._run used to accept
// `Future<dynamic> Function()`, which meant the awaited result's static
// type was `dynamic`. `Result.when()` is an *extension* method, and
// extension methods are resolved by static type, not runtime type — with
// a `dynamic` receiver there's no static type to match against, so the
// call failed at runtime with NoSuchMethodError instead of a compile
// error. `flutter analyze` doesn't catch this (dynamic is valid Dart), so
// this needs an actual runtime test, not just static analysis.
void main() {
  test('Result.when() resolves correctly through a generic function (the fix)', () async {
    Future<Result<int>> genericAction() async => const Failed(AuthFailure('nope'));

    Future<void> runGeneric<T>(Future<Result<T>> Function() action) async {
      final result = await action();
      // This must not throw NoSuchMethodError.
      result.when(success: (_) {}, failure: (_) {});
    }

    await runGeneric(genericAction); // throws if the bug regresses
  });

  test('Result.when() throws NoSuchMethodError through a dynamic-typed function (proves the bug existed)', () async {
    Future<dynamic> dynamicAction() async => const Failed<int>(AuthFailure('nope'));

    Future<void> runDynamic(Future<dynamic> Function() action) async {
      final dynamic result = await action();
      result.when(success: (_) {}, failure: (_) {});
    }

    await expectLater(runDynamic(dynamicAction), throwsA(isA<NoSuchMethodError>()));
  });
}
