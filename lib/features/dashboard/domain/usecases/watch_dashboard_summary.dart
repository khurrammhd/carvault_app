import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../vehicles/data/repositories/vehicle_repository_impl.dart';
import '../../../vehicles/domain/repositories/vehicle_repository.dart';
import '../entities/dashboard_summary.dart';

class WatchDashboardSummary {
  const WatchDashboardSummary(this._repository);
  final VehicleRepository _repository;

  Stream<DashboardSummary> call() {
    return _repository.watchVehicles().map((vehicles) {
      final sorted = [...vehicles]..sort((a, b) => b.addedAt.compareTo(a.addedAt));
      return DashboardSummary(vehicles: vehicles, recentVehicles: sorted.take(3).toList());
    });
  }
}

final watchDashboardSummaryProvider = Provider(
  (ref) => WatchDashboardSummary(ref.watch(vehicleRepositoryProvider)),
);
