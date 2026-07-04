import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/storage/app_preferences.dart';
import '../../../data/repositories/vehicle_repository_impl.dart';
import '../../../domain/entities/vehicle_entity.dart';
import '../../../domain/usecases/search_vehicles.dart';

final vehicleListSearchQueryProvider = StateProvider<String>((ref) => '');

class VehicleListFilterNotifier extends Notifier<VehicleCategoryFilter> {
  @override
  VehicleCategoryFilter build() {
    final saved = ref.watch(appPreferencesProvider).vehicleListFilter;
    return switch (saved) {
      'Buy' => VehicleCategoryFilter.buy,
      'Sell' => VehicleCategoryFilter.sell,
      _ => VehicleCategoryFilter.all,
    };
  }

  void setFilter(VehicleCategoryFilter filter) {
    state = filter;
    ref.read(appPreferencesProvider).setVehicleListFilter(switch (filter) {
      VehicleCategoryFilter.all => 'All',
      VehicleCategoryFilter.buy => 'Buy',
      VehicleCategoryFilter.sell => 'Sell',
    });
  }
}

final vehicleListFilterProvider = NotifierProvider<VehicleListFilterNotifier, VehicleCategoryFilter>(
  VehicleListFilterNotifier.new,
);

final watchAllVehiclesProvider = StreamProvider<List<VehicleEntity>>((ref) {
  return ref.watch(vehicleRepositoryProvider).watchVehicles();
});

final filteredVehiclesProvider = Provider<AsyncValue<List<VehicleEntity>>>((ref) {
  final vehiclesAsync = ref.watch(watchAllVehiclesProvider);
  final query = ref.watch(vehicleListSearchQueryProvider);
  final filter = ref.watch(vehicleListFilterProvider);
  final search = ref.watch(searchVehiclesProvider);

  return vehiclesAsync.whenData(
    (vehicles) => search(vehicles: vehicles, query: query, category: filter),
  );
});
