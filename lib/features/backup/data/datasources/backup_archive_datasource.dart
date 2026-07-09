import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../vehicles/data/datasources/vehicle_local_datasource.dart';
import '../../../vehicles/data/models/document_model.dart';
import '../../../vehicles/data/models/vehicle_model.dart';
import '../models/backup_manifest_model.dart';

/// Result of extracting a downloaded backup archive: the parsed manifest,
/// plus a map from each document's archive-relative path (matching the
/// on-disk cache layout, `documents/<vehicleId>/<fileName>`) to where its
/// bytes were written on this device's temp storage.
class BackupExtractResult {
  const BackupExtractResult({required this.manifest, required this.extractDir, required this.extractedFilePaths});
  final BackupManifestModel manifest;
  final Directory extractDir;
  final Map<String, String> extractedFilePaths;
}

/// Builds/reads the single zip archive uploaded to Drive: a `manifest.json`
/// (vehicle + document metadata) plus every document image, laid out at
/// `documents/<vehicleId>/<fileName>` — the same relative shape
/// [DocumentFileCache] uses on disk.
class BackupArchiveDataSource {
  BackupArchiveDataSource(this._vehicleLocalDataSource);
  final VehicleLocalDataSource _vehicleLocalDataSource;

  static const archiveFileName = 'carvault_backup.zip';

  Future<File> buildArchive() async {
    final vehiclesWithDocs = await _vehicleLocalDataSource.fetchAllVehiclesWithDocuments();
    final manifest = BackupManifestModel(
      version: 1,
      exportedAt: DateTime.now(),
      vehicles: vehiclesWithDocs
          .map((vwd) => VehicleModel.fromDrift(vwd.vehicle, documents: vwd.documents.map(DocumentModel.fromDrift).toList()))
          .toList(),
    );

    final archive = Archive();
    final manifestBytes = utf8.encode(jsonEncode(manifest.toJson()));
    archive.addFile(ArchiveFile('manifest.json', manifestBytes.length, manifestBytes));

    for (final vwd in vehiclesWithDocs) {
      for (final doc in vwd.documents) {
        final file = File(doc.filePath);
        if (!await file.exists()) continue; // tolerate a missing image rather than failing the whole backup
        final bytes = await file.readAsBytes();
        final archivePath = 'documents/${vwd.vehicle.id}/${p.basename(doc.filePath)}';
        archive.addFile(ArchiveFile(archivePath, bytes.length, bytes));
      }
    }

    final zipBytes = ZipEncoder().encode(archive);
    if (zipBytes == null) throw StateError('Failed to encode the backup archive.');

    final tempDir = await getTemporaryDirectory();
    final zipFile = File(p.join(tempDir.path, archiveFileName));
    await zipFile.writeAsBytes(zipBytes, flush: true);
    return zipFile;
  }

  Future<BackupExtractResult> extractArchive(File zipFile) async {
    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    final manifestFile = archive.files.firstWhere(
      (f) => f.name == 'manifest.json',
      orElse: () => throw const FormatException('Backup archive is missing manifest.json'),
    );
    final manifest =
        BackupManifestModel.fromJson(jsonDecode(utf8.decode(manifestFile.content as List<int>)) as Map<String, dynamic>);

    final tempDir = await getTemporaryDirectory();
    final extractDir = Directory(p.join(tempDir.path, 'carvault_restore_${DateTime.now().millisecondsSinceEpoch}'));
    await extractDir.create(recursive: true);

    final extractedFilePaths = <String, String>{};
    for (final file in archive.files) {
      if (!file.isFile || file.name == 'manifest.json') continue;
      final outPath = p.join(extractDir.path, file.name);
      await Directory(p.dirname(outPath)).create(recursive: true);
      await File(outPath).writeAsBytes(file.content as List<int>);
      extractedFilePaths[file.name] = outPath;
    }

    return BackupExtractResult(manifest: manifest, extractDir: extractDir, extractedFilePaths: extractedFilePaths);
  }
}

final backupArchiveDataSourceProvider = Provider<BackupArchiveDataSource>((ref) {
  return BackupArchiveDataSource(ref.watch(vehicleLocalDataSourceProvider));
});
