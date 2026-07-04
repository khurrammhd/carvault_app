import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/id_generator.dart';
import '../../data/repositories/vehicle_repository_impl.dart';
import 'add_document.dart';
import 'add_vehicle.dart';
import 'delete_document.dart';
import 'delete_vehicle.dart';

final addVehicleProvider = Provider(
  (ref) => AddVehicle(ref.watch(vehicleRepositoryProvider), ref.watch(idGeneratorProvider)),
);
final deleteVehicleProvider = Provider((ref) => DeleteVehicle(ref.watch(vehicleRepositoryProvider)));
final addDocumentProvider = Provider(
  (ref) => AddDocument(ref.watch(vehicleRepositoryProvider), ref.watch(idGeneratorProvider)),
);
final deleteDocumentProvider = Provider((ref) => DeleteDocument(ref.watch(vehicleRepositoryProvider)));
