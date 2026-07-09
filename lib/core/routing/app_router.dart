import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/backup/presentation/screens/settings_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/documents/presentation/screens/document_viewer_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/vehicles/presentation/add_vehicle/screens/add_vehicle_capture_screen.dart';
import '../../features/vehicles/presentation/add_vehicle/screens/add_vehicle_details_screen.dart';
import '../../features/vehicles/presentation/add_vehicle/screens/add_vehicle_review_screen.dart';
import '../../features/vehicles/presentation/vehicle_detail/screens/edit_vehicle_screen.dart';
import '../../features/vehicles/presentation/vehicle_detail/screens/vehicle_detail_screen.dart';
import '../../features/vehicles/presentation/vehicle_list/screens/vehicle_list_screen.dart';
import '../widgets/nav/main_navigation_shell.dart';
import 'auth_state_provider.dart';
import 'route_paths.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  // Uses `ref.listen` on the provider itself, rather than subscribing to
  // the raw repository stream directly. The raw stream only replays its
  // "current value" to whichever listener subscribes *first* — and
  // authStateProvider's own internal subscription is a second, independent
  // listener on that same stream, which would otherwise never receive that
  // replay and stay stuck in AsyncLoading() forever. `ref.listen` shares
  // Riverpod's own single, already-correct subscription instead of opening
  // a second one.
  final refreshNotifier = _RouterRefreshNotifier();
  ref.listen(authStateProvider, (previous, next) => refreshNotifier.notify());
  ref.onDispose(refreshNotifier.dispose);

  const unauthenticatedRoutes = {RoutePaths.login, RoutePaths.register, RoutePaths.forgotPassword};

  return GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: refreshNotifier,
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
        path: RoutePaths.vehicleEdit,
        builder: (context, state) => EditVehicleScreen(vehicleId: state.pathParameters['vehicleId']!),
      ),

      GoRoute(
        path: RoutePaths.documentViewer,
        builder: (context, state) => DocumentViewerScreen(
          vehicleId: state.pathParameters['vehicleId']!,
          initialDocumentIndex: int.parse(state.pathParameters['documentIndex']!),
        ),
      ),

      GoRoute(path: RoutePaths.settings, builder: (context, state) => const SettingsScreen()),
    ],
  );
});

/// A [ChangeNotifier] go_router can listen to, fed entirely by
/// [ref.listen] rather than any raw stream subscription of its own.
class _RouterRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
