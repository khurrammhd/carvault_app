import '../../../../core/errors/result.dart';
import '../../../../core/utils/id_generator.dart';
import '../entities/document_entity.dart';
import '../repositories/vehicle_repository.dart';

class AddDocument {
  const AddDocument(this._repository, this._idGenerator);
  final VehicleRepository _repository;
  final IdGenerator _idGenerator;

  Future<Result<DocumentEntity>> call({
    required String vehicleId,
    required String documentType,
    required String sourceImagePath,
  }) {
    return _repository.addDocument(
      vehicleId: vehicleId,
      documentId: _idGenerator.generate(),
      documentType: documentType,
      sourceImagePath: sourceImagePath,
    );
  }
}
