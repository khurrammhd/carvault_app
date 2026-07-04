import '../../../../core/errors/result.dart';
import '../../../../core/errors/unit.dart';
import '../entities/document_entity.dart';
import '../entities/vehicle_entity.dart';

abstract class VehicleRepository {
  Stream<List<VehicleEntity>> watchVehicles();

  Future<Result<VehicleEntity>> addVehicle(VehicleEntity vehicle);

  /// Updates an existing vehicle's editable fields (identified by
  /// [vehicle.id]). Does not touch its documents.
  Future<Result<VehicleEntity>> updateVehicle(VehicleEntity vehicle);

  Future<Result<Unit>> deleteVehicle(String vehicleId);

  Future<Result<DocumentEntity>> addDocument({
    required String vehicleId,
    required String documentId,
    required String documentType,
    required String sourceImagePath,
  });

  Future<Result<Unit>> deleteDocument(String documentId);
}
