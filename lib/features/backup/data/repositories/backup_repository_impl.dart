import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/errors/unit.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../../../core/storage/document_file_cache.dart';
import '../../../auth/data/datasources/firebase_auth_datasource.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../vehicles/data/datasources/vehicle_local_datasource.dart';
import '../../../vehicles/data/models/document_model.dart';
import '../../domain/entities/backup_settings_entity.dart';
import '../../domain/repositories/backup_repository.dart';
import '../datasources/backup_archive_datasource.dart';
import '../datasources/google_drive_datasource.dart';

class BackupRepositoryImpl implements BackupRepository {
  BackupRepositoryImpl(
    this._archiveDataSource,
    this._driveDataSource,
    this._authDataSource,
    this._authRepository,
    this._vehicleLocalDataSource,
    this._documentFileCache,
    this._prefs,
  );

  final BackupArchiveDataSource _archiveDataSource;
  final GoogleDriveDataSource _driveDataSource;
  final FirebaseAuthDataSource _authDataSource;
  final AuthRepository _authRepository;
  final VehicleLocalDataSource _vehicleLocalDataSource;
  final DocumentFileCache _documentFileCache;
  final AppPreferences _prefs;

  @override
  BackupSettingsEntity readSettings() {
    return BackupSettingsEntity(
      enabled: _prefs.backupEnabled,
      hour: _prefs.backupHour,
      minute: _prefs.backupMinute,
      connectedDriveAccountEmail: _prefs.connectedDriveAccountEmail,
      lastBackupAt: _prefs.lastBackupAt,
      lastBackupSucceeded: _prefs.lastBackupSucceeded,
    );
  }

  @override
  Future<void> updateSchedule({required bool enabled, required int hour, required int minute}) async {
    await _prefs.setBackupEnabled(enabled);
    await _prefs.setBackupTime(hour: hour, minute: minute);
  }

  @override
  Future<Result<Unit>> performBackup() async {
    final apiResult = await _authenticatedDriveApi();
    return apiResult.when(
      success: _uploadBackup,
      failure: (f) async {
        await _prefs.setLastBackupSucceeded(false);
        return Failed<Unit>(f);
      },
    );
  }

  @override
  Future<Result<Unit>> restoreLatestBackup() async {
    final apiResult = await _authenticatedDriveApi();
    return apiResult.when(success: _downloadAndRestore, failure: (f) async => Failed<Unit>(f));
  }

  /// Builds a Drive client from the connected Google account. Fails with
  /// [AuthFailure] if Drive was never connected, or the cached account's
  /// token can no longer be silently refreshed (the user must reconnect).
  Future<Result<drive.DriveApi>> _authenticatedDriveApi() async {
    final account = _authDataSource.currentGoogleAccount ?? await _authDataSource.signInSilently();
    if (account == null) {
      return const Failed(AuthFailure('Google Drive is not connected. Connect it from Settings.'));
    }
    final client = await _authDataSource.authenticatedDriveClient();
    if (client == null) {
      return const Failed(AuthFailure('Could not authenticate with Google Drive. Try reconnecting in Settings.'));
    }
    return Success(drive.DriveApi(client));
  }

  String _backupFileNameFor(String userId) => 'carvault_backup_$userId.zip';

  Future<Result<Unit>> _uploadBackup(drive.DriveApi api) async {
    try {
      final userId = _authRepository.currentUser?.id;
      if (userId == null) return const Failed(AuthFailure('Not signed in.'));

      final zipFile = await _archiveDataSource.buildArchive();
      final folderId = await _driveDataSource.findOrCreateBackupFolder(api);
      await _driveDataSource.uploadOrReplace(
        api: api,
        folderId: folderId,
        fileName: _backupFileNameFor(userId),
        localFile: zipFile,
      );

      await _prefs.setLastBackupAt(DateTime.now());
      await _prefs.setLastBackupSucceeded(true);
      return const Success(Unit.value);
    } catch (e) {
      await _prefs.setLastBackupSucceeded(false);
      return Failed(NetworkFailure(e.toString()));
    }
  }

  Future<Result<Unit>> _downloadAndRestore(drive.DriveApi api) async {
    try {
      final userId = _authRepository.currentUser?.id;
      if (userId == null) return const Failed(AuthFailure('Not signed in.'));

      final folderId = await _driveDataSource.findOrCreateBackupFolder(api);
      final tempDir = await getTemporaryDirectory();
      final downloadFile = File(p.join(tempDir.path, 'carvault_restore_download.zip'));

      final downloaded = await _driveDataSource.downloadLatest(
        api: api,
        folderId: folderId,
        fileName: _backupFileNameFor(userId),
        destination: downloadFile,
      );
      if (downloaded == null) {
        return const Failed(UnexpectedFailure('No backup was found in Google Drive yet.'));
      }

      final extracted = await _archiveDataSource.extractArchive(downloaded);

      // Copy every extracted image into this install's real cache location
      // *before* touching the DB, so a mid-transaction failure can't leave
      // DB rows pointing at files that don't exist.
      await _documentFileCache.clearAll();
      final restoredFilePaths = <String, String>{}; // documentId -> new absolute path
      for (final vehicle in extracted.manifest.vehicles) {
        for (final doc in vehicle.documents) {
          final archiveKey = 'documents/${vehicle.id}/${p.basename(doc.filePath)}';
          final extractedPath = extracted.extractedFilePaths[archiveKey];
          if (extractedPath == null) continue; // image wasn't in the archive — skip this document
          restoredFilePaths[doc.id] = await _documentFileCache.store(
            sourcePath: extractedPath,
            vehicleId: vehicle.id,
            documentId: doc.id,
          );
        }
      }

      await _vehicleLocalDataSource.transaction(() async {
        await _vehicleLocalDataSource.clearAll();
        for (final vehicle in extracted.manifest.vehicles) {
          await _vehicleLocalDataSource.insertVehicle(vehicle.toCompanion());
          for (final doc in vehicle.documents) {
            final newPath = restoredFilePaths[doc.id];
            if (newPath == null) continue; // no image was recovered for this document — drop the row
            final restoredDoc = DocumentModel(
              id: doc.id,
              vehicleId: doc.vehicleId,
              type: doc.type,
              fileName: doc.fileName,
              filePath: newPath,
              uploadedAt: doc.uploadedAt,
            );
            await _vehicleLocalDataSource.insertDocument(restoredDoc.toCompanion());
          }
        }
      });

      await extracted.extractDir.delete(recursive: true);
      await downloaded.delete();

      return const Success(Unit.value);
    } catch (e) {
      return Failed(UnexpectedFailure(e.toString()));
    }
  }
}

final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  return BackupRepositoryImpl(
    ref.watch(backupArchiveDataSourceProvider),
    ref.watch(googleDriveDataSourceProvider),
    ref.watch(firebaseAuthDataSourceProvider),
    ref.watch(authRepositoryProvider),
    ref.watch(vehicleLocalDataSourceProvider),
    ref.watch(documentFileCacheProvider),
    ref.watch(appPreferencesProvider),
  );
});
