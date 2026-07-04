import '../../../../core/errors/result.dart';
import '../entities/add_vehicle_draft.dart';
import '../entities/vehicle_entity.dart';
import '../repositories/vehicle_repository.dart';

class UpdateVehicle {
  const UpdateVehicle(this._repository);
  final VehicleRepository _repository;

  Future<Result<VehicleEntity>> call({
    required String vehicleId,
    required AddVehicleDraft draft,
    required DateTime originalAddedAt,
  }) async {
    final validation = draft.validate();
    if (validation case Failed(:final failure)) return Failed(failure);

    final vehicle = VehicleEntity(
      id: vehicleId,
      regNumber: draft.regNumber.trim().toUpperCase(),
      make: draft.make.trim(),
      model: draft.model.trim(),
      year: draft.year.trim(),
      category: draft.category,
      notes: draft.notes?.trim(),
      addedAt: originalAddedAt,
      documents: const [],
    );

    return _repository.updateVehicle(vehicle);
  }
}
