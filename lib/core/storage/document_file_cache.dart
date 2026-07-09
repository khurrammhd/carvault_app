import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Local file-system cache for captured document images. Drift only ever
/// stores a file *path* for a document — the image itself lives here, in
/// the app's private sandboxed storage.
class DocumentFileCache {
  Future<String> store({
    required String sourcePath,
    required String vehicleId,
    required String documentId,
  }) async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final extension = p.extension(sourcePath);
    final vehicleDir = Directory(p.join(documentsDir.path, 'documents', vehicleId));
    await vehicleDir.create(recursive: true);

    final destinationPath = p.join(vehicleDir.path, '$documentId$extension');
    await File(sourcePath).copy(destinationPath);
    return destinationPath;
  }

  Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }

  Future<void> deleteVehicleFiles(String vehicleId) async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final vehicleDir = Directory(p.join(documentsDir.path, 'documents', vehicleId));
    if (await vehicleDir.exists()) await vehicleDir.delete(recursive: true);
  }

  /// The root `documents/` directory every vehicle's files live under —
  /// used by the backup feature to zip everything in one pass.
  Future<Directory> documentsRootDir() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    return Directory(p.join(documentsDir.path, 'documents'));
  }

  /// Deletes every cached document image. Used by restore to replace local
  /// files with a downloaded backup's contents.
  Future<void> clearAll() async {
    final dir = await documentsRootDir();
    if (await dir.exists()) await dir.delete(recursive: true);
  }
}

final documentFileCacheProvider = Provider<DocumentFileCache>((ref) => DocumentFileCache());
