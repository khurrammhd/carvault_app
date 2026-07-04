import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/routing/route_paths.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/buttons/app_fab.dart';
import '../../../domain/entities/vehicle_entity.dart';
import '../../widgets/vehicle_list_item.dart';
import '../providers/vehicle_list_providers.dart';
import '../widgets/category_filter_chips.dart';
import '../widgets/vehicle_search_field.dart';

class VehicleListScreen extends ConsumerStatefulWidget {
  const VehicleListScreen({super.key});

  @override
  ConsumerState<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends ConsumerState<VehicleListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredAsync = ref.watch(filteredVehiclesProvider);
    final selectedFilter = ref.watch(vehicleListFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 18, 20, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('My Vehicles', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.text)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: VehicleSearchField(
                  controller: _searchController,
                  onChanged: (value) => ref.read(vehicleListSearchQueryProvider.notifier).state = value,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: CategoryFilterChips(
                    selected: selectedFilter,
                    onSelected: (value) => ref.read(vehicleListFilterProvider.notifier).setFilter(value),
                  ),
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: filteredAsync.when(
                    loading: () => const Center(key: ValueKey('loading'), child: CircularProgressIndicator()),
                    error: (error, _) => Center(
                      key: const ValueKey('error'),
                      child: Text("Couldn't load your vehicles: $error"),
                    ),
                    data: (vehicles) => _VehicleListResults(key: const ValueKey('data'), vehicles: vehicles),
                  ),
                ),
              ),
            ],
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

class _VehicleListResults extends StatelessWidget {
  const _VehicleListResults({required this.vehicles, super.key});
  final List<VehicleEntity> vehicles;

  @override
  Widget build(BuildContext context) {
    if (vehicles.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: Text('No vehicles match your search.', style: TextStyle(fontSize: 14, color: AppColors.textFaint)),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 100),
      itemCount: vehicles.length,
      separatorBuilder: (context, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        return VehicleListItem(
          vehicle: vehicle,
          subtitle: '${vehicle.make} ${vehicle.model} · ${vehicle.year}',
          onTap: () => context.push(RoutePaths.vehicleDetailPath(vehicle.id)),
        );
      },
    );
  }
}
