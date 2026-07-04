import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../entities/vehicle_entity.dart';

enum VehicleCategoryFilter { all, buy, sell }

/// Pure, synchronous filtering rule: combined reg./make/model haystake,
/// AND'd with the category filter.
class SearchVehicles {
  const SearchVehicles();

  List<VehicleEntity> call({
    required List<VehicleEntity> vehicles,
    required String query,
    required VehicleCategoryFilter category,
  }) {
    final normalizedQuery = query.trim().toLowerCase();

    return vehicles.where((vehicle) {
      final matchesCategory = switch (category) {
        VehicleCategoryFilter.all => true,
        VehicleCategoryFilter.buy => vehicle.category == VehicleCategory.buy,
        VehicleCategoryFilter.sell => vehicle.category == VehicleCategory.sell,
      };
      if (!matchesCategory) return false;
      if (normalizedQuery.isEmpty) return true;

      final haystack = '${vehicle.regNumber}${vehicle.make}${vehicle.model}'.toLowerCase();
      return haystack.contains(normalizedQuery);
    }).toList();
  }
}

final searchVehiclesProvider = Provider<SearchVehicles>((ref) => const SearchVehicles());
