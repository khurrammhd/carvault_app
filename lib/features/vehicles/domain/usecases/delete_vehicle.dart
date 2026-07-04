import '../../../../core/errors/result.dart';
import '../../../../core/errors/unit.dart';
import '../repositories/vehicle_repository.dart';

class DeleteVehicle {
  const DeleteVehicle(this._repository);
  final VehicleRepository _repository;

  Future<Result<Unit>> call(String vehicleId) => _repository.deleteVehicle(vehicleId);
}
