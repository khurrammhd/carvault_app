import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/add_vehicle_draft.dart';
import '../../../domain/entities/vehicle_entity.dart';

class AddVehicleDraftNotifier extends Notifier<AddVehicleDraft> {
  @override
  AddVehicleDraft build() => const AddVehicleDraft();

  void setPhotoPath(String path) => state = state.copyWith(photoPath: path);
  void setRegNumber(String value) => state = state.copyWith(regNumber: value.toUpperCase());
  void setMake(String value) => state = state.copyWith(make: value);
  void setModel(String value) => state = state.copyWith(model: value);
  void setYear(String value) => state = state.copyWith(year: value);
  void setCategory(VehicleCategory category) => state = state.copyWith(category: category);
  void setNotes(String value) => state = state.copyWith(notes: value);
  void reset() => state = const AddVehicleDraft();
}

final addVehicleDraftProvider = NotifierProvider<AddVehicleDraftNotifier, AddVehicleDraft>(AddVehicleDraftNotifier.new);
