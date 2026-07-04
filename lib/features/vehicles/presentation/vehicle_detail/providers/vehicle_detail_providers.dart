import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/vehicle_entity.dart';
import '../../vehicle_list/providers/vehicle_list_providers.dart';

final vehicleByIdProvider = Provider.family<AsyncValue<VehicleEntity?>, String>((ref, vehicleId) {
  final vehiclesAsync = ref.watch(watchAllVehiclesProvider);
  return vehiclesAsync.whenData((vehicles) {
    for (final vehicle in vehicles) {
      if (vehicle.id == vehicleId) return vehicle;
    }
    return null;
  });
});
