import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import 'vehicle_entity.dart';

/// The in-progress state of the Add Vehicle 3-step flow, before it
/// becomes a real [VehicleEntity]. Not serialized anywhere — cleared on
/// cancel/save.
class AddVehicleDraft {
  const AddVehicleDraft({
    this.photoPath,
    this.regNumber = '',
    this.make = '',
    this.model = '',
    this.year = '',
    this.category = VehicleCategory.buy,
    this.notes,
  });

  final String? photoPath;
  final String regNumber;
  final String make;
  final String model;
  final String year;
  final VehicleCategory category;
  final String? notes;

  /// Mirrors the design spec: "Continue is disabled until Registration
  /// number is non-empty. No other field is required in v1."
  bool get canContinue => regNumber.trim().isNotEmpty;

  AddVehicleDraft copyWith({
    String? photoPath,
    String? regNumber,
    String? make,
    String? model,
    String? year,
    VehicleCategory? category,
    String? notes,
  }) {
    return AddVehicleDraft(
      photoPath: photoPath ?? this.photoPath,
      regNumber: regNumber ?? this.regNumber,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      category: category ?? this.category,
      notes: notes ?? this.notes,
    );
  }

  Result<AddVehicleDraft> validate() {
    if (regNumber.trim().isEmpty) {
      return const Failed(ValidationFailure('Registration number is required.'));
    }
    return Success(this);
  }
}
