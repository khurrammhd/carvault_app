import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/documents_table.dart';
import 'tables/vehicles_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Vehicles, Documents])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          // SQLite disables FK enforcement per-connection by default, so the
          // `ON DELETE CASCADE` on documents.vehicle_id (documents_table.dart)
          // has never actually fired. Enable it here, and purge any document
          // rows already orphaned by a pre-fix vehicle deletion — otherwise
          // they collide on `documents.id` the next time a backup restore
          // re-inserts a document with the same id.
          await customStatement('PRAGMA foreign_keys = ON');
          await customStatement(
            'DELETE FROM documents WHERE vehicle_id NOT IN (SELECT id FROM vehicles)',
          );
        },
      );

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'carvault.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
