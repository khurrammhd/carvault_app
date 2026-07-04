import '../../../../core/errors/result.dart';
import '../../../../core/utils/id_generator.dart';
import '../entities/add_vehicle_draft.dart';
import '../entities/vehicle_entity.dart';
import '../repositories/vehicle_repository.dart';

class AddVehicle {
  const AddVehicle(this._repository, this._idGenerator);
  final VehicleRepository _repository;
  final IdGenerator _idGenerator;

  Future<Result<VehicleEntity>> call(AddVehicleDraft draft) async {
    final validation = draft.validate();
    if (validation case Failed(:final failure)) return Failed(failure);

    final vehicle = VehicleEntity(
      id: _idGenerator.generate(),
      regNumber: draft.regNumber.trim().toUpperCase(),
      make: draft.make.trim(),
      model: draft.model.trim(),
      year: draft.year.trim(),
      category: draft.category,
      notes: draft.notes?.trim(),
      addedAt: DateTime.now(),
      documents: const [],
    );

    return _repository.addVehicle(vehicle);
  }
}
