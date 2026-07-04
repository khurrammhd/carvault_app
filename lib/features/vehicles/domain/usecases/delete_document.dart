import '../../../../core/errors/result.dart';
import '../../../../core/errors/unit.dart';
import '../repositories/vehicle_repository.dart';

class DeleteDocument {
  const DeleteDocument(this._repository);
  final VehicleRepository _repository;

  Future<Result<Unit>> call(String documentId) => _repository.deleteDocument(documentId);
}
