import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/errors/unit.dart';
import '../../../../core/storage/document_file_cache.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../datasources/vehicle_local_datasource.dart';
import '../models/document_model.dart';
import '../models/vehicle_model.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  VehicleRepositoryImpl(this._dataSource, this._fileCache);

  final VehicleLocalDataSource _dataSource;
  final DocumentFileCache _fileCache;

  @override
  Stream<List<VehicleEntity>> watchVehicles() {
    return _dataSource.watchVehiclesWithDocuments().map((rows) {
      return rows.map((r) {
        final documents = r.documents.map(DocumentModel.fromDrift).toList();
        return VehicleModel.fromDrift(r.vehicle, documents: documents).toEntity();
      }).toList();
    });
  }

  @override
  Future<Result<VehicleEntity>> addVehicle(VehicleEntity vehicle) {
    final modelResult = VehicleModel.create(
      id: vehicle.id,
      regNumber: vehicle.regNumber,
      make: vehicle.make,
      model: vehicle.model,
      year: vehicle.year,
      category: vehicle.category,
      notes: vehicle.notes,
      addedAt: vehicle.addedAt,
    );

    return modelResult.when(
      success: (model) async {
        try {
          await _dataSource.insertVehicle(model.toCompanion());
          return Success(model.toEntity());
        } catch (e) {
          return Failed(UnexpectedFailure(e.toString()));
        }
      },
      failure: (f) async => Failed<VehicleEntity>(f),
    );
  }

  @override
  Future<Result<Unit>> deleteVehicle(String vehicleId) async {
    try {
      await _dataSource.deleteVehicleRow(vehicleId);
      await _fileCache.deleteVehicleFiles(vehicleId);
      return const Success(Unit.value);
    } catch (e) {
      return Failed(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<DocumentEntity>> addDocument({
    required String vehicleId,
    required String documentId,
    required String documentType,
    required String sourceImagePath,
  }) async {
    final String permanentPath;
    try {
      permanentPath = await _fileCache.store(
        sourcePath: sourceImagePath,
        vehicleId: vehicleId,
        documentId: documentId,
      );
    } catch (e) {
      return Failed(UnexpectedFailure(e.toString()));
    }

    final modelResult = DocumentModel.create(
      id: documentId,
      vehicleId: vehicleId,
      type: documentType == 'Other' ? DocumentKind.other : DocumentKind.registrationCertificate,
      fileName: p.basename(permanentPath),
      filePath: permanentPath,
    );

    return modelResult.when(
      success: (model) async {
        try {
          await _dataSource.insertDocument(model.toCompanion());
          return Success(model.toEntity());
        } catch (e) {
          await _fileCache.deleteFile(permanentPath);
          return Failed(UnexpectedFailure(e.toString()));
        }
      },
      failure: (f) async {
        await _fileCache.deleteFile(permanentPath);
        return Failed<DocumentEntity>(f);
      },
    );
  }

  @override
  Future<Result<Unit>> deleteDocument(String documentId) async {
    try {
      final row = await _dataSource.getDocumentById(documentId);
      if (row == null) return const Failed(UnexpectedFailure('Document not found.'));

      await _dataSource.deleteDocumentRow(documentId);
      await _fileCache.deleteFile(row.filePath);
      return const Success(Unit.value);
    } catch (e) {
      return Failed(UnexpectedFailure(e.toString()));
    }
  }
}

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return VehicleRepositoryImpl(
    ref.watch(vehicleLocalDataSourceProvider),
    ref.watch(documentFileCacheProvider),
  );
});
