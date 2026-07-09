import '../../../vehicles/data/models/vehicle_model.dart';

/// The JSON file (`manifest.json`) written into every backup archive.
/// Reuses [VehicleModel.toJson]/`fromJson` as-is — documents already nest
/// inside a vehicle's JSON, so no separate document list is needed here.
class BackupManifestModel {
  const BackupManifestModel({
    required this.version,
    required this.exportedAt,
    required this.vehicles,
  });

  final int version;
  final DateTime exportedAt;
  final List<VehicleModel> vehicles;

  factory BackupManifestModel.fromJson(Map<String, dynamic> json) {
    return BackupManifestModel(
      version: json['version'] as int,
      exportedAt: DateTime.parse(json['exportedAt'] as String),
      vehicles: (json['vehicles'] as List<dynamic>)
          .map((v) => VehicleModel.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'version': version,
        'exportedAt': exportedAt.toIso8601String(),
        'vehicles': vehicles.map((v) => v.toJson()).toList(),
      };
}
