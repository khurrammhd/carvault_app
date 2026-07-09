import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/auth_state_provider.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/buttons/app_fab.dart';
import '../../../auth/presentation/providers/just_registered_provider.dart';
import '../../../backup/presentation/widgets/connect_drive_prompt_dialog.dart';
import '../../../vehicles/presentation/widgets/vehicle_list_item.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/staggered_entrance.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final width = MediaQuery.sizeOf(context).width;
    final contentMaxWidth = width > 600 ? 480.0 : double.infinity;

    // Every freshly-authenticated user lands here per the router's redirect
    // logic, so this is where the one-time "back up to Google Drive?"
    // prompt fires. Re-checks the flag's *current* value inside the
    // callback (not the value captured at build time) so scheduling this
    // more than once across rebuilds can't show the dialog twice.
    if (ref.watch(justRegisteredProvider)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted || !ref.read(justRegisteredProvider)) return;
        ref.read(justRegisteredProvider.notifier).state = false;
        showDialog(context: context, builder: (_) => const ConnectDrivePromptDialog());
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentMaxWidth),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: summaryAsync.when(
                  loading: () => const Center(key: ValueKey('loading'), child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    key: const ValueKey('error'),
                    child: Text("Couldn't load your dashboard: $error"),
                  ),
                  data: (summary) => _DashboardContent(key: const ValueKey('data'), summary: summary),
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: AppFab(onTap: () => context.push(RoutePaths.addVehicleCapture)),
          ),
        ],
      ),
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  const _DashboardContent({required this.summary, super.key});
  final DashboardSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DashboardHeader(user: user),
        // `Transform.translate` is used instead of a negative top padding —
        // negative EdgeInsets values trip a `RenderShiftedBox` assertion
        // ("isNonNegative is not true") in this Flutter version. Transform
        // only shifts the *visual* position, not the layout box, so the
        // top padding of the section below is reduced to compensate for
        // the space Transform doesn't reclaim.
        Transform.translate(
          offset: const Offset(0, -28),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(child: StatCard(value: summary.totalVehicleCount, label: 'Vehicles stored')),
                const SizedBox(width: 12),
                Expanded(child: StatCard(value: summary.totalDocumentCount, label: 'Documents stored')),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Your vehicles', style: AppTextStyles.sectionHeader),
              TextButton(
                onPressed: () => context.go(RoutePaths.vehicles),
                child: const Text('See all', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 100),
          child: summary.recentVehicles.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      'No vehicles yet. Tap + to add your first one.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: AppColors.textFaint),
                    ),
                  ),
                )
              : Column(
                  children: [
                    for (final (index, vehicle) in summary.recentVehicles.indexed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: StaggeredEntrance(
                          index: index,
                          child: VehicleListItem(
                            vehicle: vehicle,
                            subtitle: '${vehicle.make} ${vehicle.model} · ${vehicle.documentCount} docs',
                            onTap: () => context.push(RoutePaths.vehicleDetailPath(vehicle.id)),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}
