import 'package:drift/drift.dart';

@DataClassName('Vehicle')
class Vehicles extends Table {
  TextColumn get id => text()();
  TextColumn get regNumber => text()();
  TextColumn get make => text()();
  TextColumn get model => text()();
  TextColumn get year => text()();
  TextColumn get category => text()(); // 'Buy' | 'Sell'
  TextColumn get notes => text().nullable()();
  DateTimeColumn get addedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
