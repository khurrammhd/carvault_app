import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/auth_state_provider.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../auth/presentation/providers/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (user != null) ...[
              Text(user.email, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
            ],
            OutlinedButton(
              onPressed: () => context.push(RoutePaths.settings),
              child: const Text('Settings'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => ref.read(authControllerProvider.notifier).logout(),
              child: const Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}
