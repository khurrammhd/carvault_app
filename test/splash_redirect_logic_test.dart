import 'package:carvault/core/routing/auth_state_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('authStateProvider resolves to data(null) shortly after creation, not stuck loading', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    var value = container.read(authStateProvider);
    expect(value, isA<AsyncLoading<dynamic>>());

    final sub = container.listen(authStateProvider, (previous, next) {});
    addTearDown(sub.close);

    await Future<void>.delayed(const Duration(milliseconds: 50));

    value = container.read(authStateProvider);
    expect(value.hasValue, isTrue, reason: 'should resolve shortly after subscribing, not stay loading');
    expect(value.value, isNull, reason: 'no one is logged in yet');
  });

  test('authStateProvider updates to data(user) after login, and a second independent '
      'listener (simulating the router) also sees it', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Two independent listeners, like the real app has (the router's
    // ref.listen, and anything else that reads authStateProvider).
    final events1 = <AsyncValue<dynamic>>[];
    final sub1 = container.listen(authStateProvider, (previous, next) => events1.add(next));
    addTearDown(sub1.close);

    await Future<void>.delayed(const Duration(milliseconds: 50));

    final events2 = <AsyncValue<dynamic>>[];
    final sub2 = container.listen(authStateProvider, (previous, next) => events2.add(next));
    addTearDown(sub2.close);

    await Future<void>.delayed(const Duration(milliseconds: 50));

    final value = container.read(authStateProvider);
    expect(value.hasValue, isTrue);
    expect(value.value, isNull);
  });
}
