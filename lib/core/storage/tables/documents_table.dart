import 'package:drift/drift.dart';

import 'vehicles_table.dart';

@DataClassName('Document')
class Documents extends Table {
  TextColumn get id => text()();
  TextColumn get vehicleId => text().references(Vehicles, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => text()(); // 'Registration Certificate' | 'Other'
  TextColumn get fileName => text()();
  TextColumn get filePath => text()();
  DateTimeColumn get uploadedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
