import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/drive/v3.dart' as drive;

/// The visible folder created in the user's own Drive — chosen per the
/// `drive.file` scope so backups are something the user can find and
/// inspect outside the app, not a hidden app-data blob.
const backupFolderName = 'CarVault Backups';

/// Thin wrapper around `drive.DriveApi` calls. Stateless by design — every
/// method takes an already-authenticated [drive.DriveApi] built by the
/// caller ([BackupRepositoryImpl]), so this class never touches Google
/// Sign-In or auth tokens itself.
class GoogleDriveDataSource {
  const GoogleDriveDataSource();

  Future<String> findOrCreateBackupFolder(drive.DriveApi api) async {
    final existing = await api.files.list(
      q: "mimeType='application/vnd.google-apps.folder' and name='$backupFolderName' and trashed=false",
      spaces: 'drive',
      $fields: 'files(id,name)',
    );
    final files = existing.files;
    if (files != null && files.isNotEmpty && files.first.id != null) {
      return files.first.id!;
    }

    final created = await api.files.create(
      drive.File(name: backupFolderName, mimeType: 'application/vnd.google-apps.folder'),
    );
    return created.id!;
  }

  /// Atomic single-file replace: updates the existing backup file in place
  /// if one exists, otherwise creates it. Never leaves two backup files
  /// behind.
  Future<void> uploadOrReplace({
    required drive.DriveApi api,
    required String folderId,
    required String fileName,
    required File localFile,
  }) async {
    final existingId = await _findFileId(api, folderId: folderId, fileName: fileName);
    final length = await localFile.length();
    final media = drive.Media(localFile.openRead(), length);

    if (existingId != null) {
      await api.files.update(drive.File(), existingId, uploadMedia: media);
    } else {
      await api.files.create(drive.File(name: fileName, parents: [folderId]), uploadMedia: media);
    }
  }

  /// Downloads the backup into [destination]. Returns `null` if no backup
  /// exists yet for this user — a normal outcome the first time Restore is
  /// tried, not an error.
  Future<File?> downloadLatest({
    required drive.DriveApi api,
    required String folderId,
    required String fileName,
    required File destination,
  }) async {
    final fileId = await _findFileId(api, folderId: folderId, fileName: fileName);
    if (fileId == null) return null;

    final media = await api.files.get(fileId, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
    final sink = destination.openWrite();
    await media.stream.pipe(sink);
    return destination;
  }

  /// Looks the backup up by well-known folder + file name rather than a
  /// remembered file ID — required because `drive.file` scope only grants
  /// visibility into files the app itself created, and a fresh
  /// install/reinstall has no locally-remembered ID to look up by.
  Future<String?> _findFileId(drive.DriveApi api, {required String folderId, required String fileName}) async {
    final result = await api.files.list(
      q: "'$folderId' in parents and name='$fileName' and trashed=false",
      spaces: 'drive',
      $fields: 'files(id,name)',
    );
    final files = result.files;
    if (files != null && files.isNotEmpty) return files.first.id;
    return null;
  }
}

final googleDriveDataSourceProvider = Provider<GoogleDriveDataSource>((ref) => const GoogleDriveDataSource());
