import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/environment.dart';
import '../core/routing/app_router.dart';
import '../core/theme/app_theme.dart';

class CarVaultApp extends ConsumerWidget {
  const CarVaultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'CarVault${Environment.current.appNameSuffix}',
      debugShowCheckedModeBanner: !Environment.current.isProduction,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
