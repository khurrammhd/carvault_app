import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/repositories/fake_auth_repository.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/documents/presentation/screens/document_viewer_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/vehicles/presentation/add_vehicle/screens/add_vehicle_capture_screen.dart';
import '../../features/vehicles/presentation/add_vehicle/screens/add_vehicle_details_screen.dart';
import '../../features/vehicles/presentation/add_vehicle/screens/add_vehicle_review_screen.dart';
import '../../features/vehicles/presentation/vehicle_detail/screens/vehicle_detail_screen.dart';
import '../../features/vehicles/presentation/vehicle_list/screens/vehicle_list_screen.dart';
import '../widgets/nav/main_navigation_shell.dart';
import 'auth_state_provider.dart';
import 'route_paths.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final refreshStream = GoRouterRefreshStream(ref.watch(authRepositoryProvider).authStateChanges);
  ref.onDispose(refreshStream.dispose);

  const unauthenticatedRoutes = {RoutePaths.login, RoutePaths.register, RoutePaths.forgotPassword};

  return GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: refreshStream,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final atSplash = state.matchedLocation == RoutePaths.splash;
      final atUnauthRoute = unauthenticatedRoutes.contains(state.matchedLocation);

      return authState.when(
        loading: () => atSplash ? null : RoutePaths.splash,
        error: (error, stackTrace) => atUnauthRoute ? null : RoutePaths.login,
        data: (user) {
          final isLoggedIn = user != null;
          if (!isLoggedIn) return atUnauthRoute ? null : RoutePaths.login;
          if (atSplash || atUnauthRoute) return RoutePaths.dashboard;
          return null;
        },
      );
    },
    routes: [
      GoRoute(path: RoutePaths.splash, builder: (context, state) => const SplashScreen()),
      GoRoute(path: RoutePaths.login, builder: (context, state) => const LoginScreen()),
      GoRoute(path: RoutePaths.register, builder: (context, state) => const RegisterScreen()),
      GoRoute(path: RoutePaths.forgotPassword, builder: (context, state) => const ForgotPasswordScreen()),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainNavigationShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: RoutePaths.dashboard, builder: (context, state) => const DashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: RoutePaths.vehicles, builder: (context, state) => const VehicleListScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: RoutePaths.profile, builder: (context, state) => const ProfileScreen()),
          ]),
        ],
      ),

      GoRoute(
        path: RoutePaths.addVehicleCapture,
        builder: (context, state) => const AddVehicleCaptureScreen(),
        routes: [
          GoRoute(path: 'details', builder: (context, state) => const AddVehicleDetailsScreen()),
          GoRoute(path: 'review', builder: (context, state) => const AddVehicleReviewScreen()),
        ],
      ),

      GoRoute(
        path: RoutePaths.vehicleDetail,
        builder: (context, state) => VehicleDetailScreen(vehicleId: state.pathParameters['vehicleId']!),
      ),

      GoRoute(
        path: RoutePaths.documentViewer,
        builder: (context, state) => DocumentViewerScreen(
          vehicleId: state.pathParameters['vehicleId']!,
          initialDocumentIndex: int.parse(state.pathParameters['documentIndex']!),
        ),
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
