import '../../../vehicles/domain/entities/vehicle_entity.dart';

class DashboardSummary {
  const DashboardSummary({required this.vehicles, required this.recentVehicles});

  final List<VehicleEntity> vehicles;
  final List<VehicleEntity> recentVehicles;

  int get totalVehicleCount => vehicles.length;
  int get totalDocumentCount => vehicles.fold(0, (sum, v) => sum + v.documentCount);
}
