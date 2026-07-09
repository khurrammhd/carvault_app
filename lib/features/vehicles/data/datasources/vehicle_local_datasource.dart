import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/storage/app_database.dart';

class VehicleWithDocuments {
  const VehicleWithDocuments({required this.vehicle, required this.documents});
  final Vehicle vehicle;
  final List<Document> documents;
}

class VehicleLocalDataSource {
  VehicleLocalDataSource(this._db);
  final AppDatabase _db;

  Stream<List<VehicleWithDocuments>> watchVehiclesWithDocuments() {
    final vehiclesStream = _db.select(_db.vehicles).watch();
    final documentsStream = _db.select(_db.documents).watch();

    return Rx.combineLatest2(vehiclesStream, documentsStream, (vehicles, documents) {
      return vehicles.map((vehicle) {
        final docs = documents.where((d) => d.vehicleId == vehicle.id).toList()
          ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
        return VehicleWithDocuments(vehicle: vehicle, documents: docs);
      }).toList();
    });
  }

  /// One-shot equivalent of [watchVehiclesWithDocuments], for the backup
  /// feature's export — a live `Stream` isn't the right shape for "read
  /// everything once and zip it up".
  Future<List<VehicleWithDocuments>> fetchAllVehiclesWithDocuments() async {
    final vehicles = await _db.select(_db.vehicles).get();
    final documents = await _db.select(_db.documents).get();
    return vehicles.map((vehicle) {
      final docs = documents.where((d) => d.vehicleId == vehicle.id).toList()
        ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
      return VehicleWithDocuments(vehicle: vehicle, documents: docs);
    }).toList();
  }

  /// Deletes every vehicle row — documents cascade via the existing FK.
  /// Used by restore to replace local data with a downloaded backup.
  Future<void> clearAll() => _db.delete(_db.vehicles).go();

  /// Exposes Drift's transaction wrapper so restore can clear + re-insert
  /// atomically, without the backup feature reaching into [AppDatabase]
  /// directly.
  Future<void> transaction(Future<void> Function() action) => _db.transaction(action);

  Future<void> insertVehicle(VehiclesCompanion companion) {
    return _db.into(_db.vehicles).insert(companion);
  }

  Future<void> updateVehicle(VehiclesCompanion companion) {
    return (_db.update(_db.vehicles)..where((v) => v.id.equals(companion.id.value))).write(companion);
  }

  Future<void> deleteVehicleRow(String vehicleId) {
    return (_db.delete(_db.vehicles)..where((v) => v.id.equals(vehicleId))).go();
  }

  Future<void> insertDocument(DocumentsCompanion companion) {
    return _db.into(_db.documents).insert(companion);
  }

  Future<Document?> getDocumentById(String documentId) {
    return (_db.select(_db.documents)..where((d) => d.id.equals(documentId))).getSingleOrNull();
  }

  Future<void> deleteDocumentRow(String documentId) {
    return (_db.delete(_db.documents)..where((d) => d.id.equals(documentId))).go();
  }
}

final vehicleLocalDataSourceProvider = Provider<VehicleLocalDataSource>((ref) {
  return VehicleLocalDataSource(ref.watch(appDatabaseProvider));
});
