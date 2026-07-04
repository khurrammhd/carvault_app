import 'package:drift/drift.dart' show Value;

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/storage/app_database.dart' show Vehicle, VehiclesCompanion;
import '../../domain/entities/vehicle_entity.dart';
import 'document_model.dart';

/// Serializable, validated representation of a vehicle record.
class VehicleModel {
  const VehicleModel({
    required this.id,
    required this.regNumber,
    required this.make,
    required this.model,
    required this.year,
    required this.category,
    required this.addedAt,
    this.notes,
    this.documents = const [],
  });

  final String id;
  final String regNumber;
  final String make;
  final String model;
  final String year;
  final VehicleCategory category;
  final DateTime addedAt;
  final String? notes;
  final List<DocumentModel> documents;

  /// Only registration number is required, per the design spec.
  static Result<VehicleModel> create({
    required String id,
    required String regNumber,
    String make = '',
    String model = '',
    String year = '',
    VehicleCategory category = VehicleCategory.buy,
    String? notes,
    DateTime? addedAt,
    List<DocumentModel> documents = const [],
  }) {
    final trimmedReg = regNumber.trim();
    if (trimmedReg.isEmpty) {
      return const Failed(ValidationFailure('Registration number is required.'));
    }
    return Success(VehicleModel(
      id: id,
      regNumber: trimmedReg.toUpperCase(),
      make: make.trim(),
      model: model.trim(),
      year: year.trim(),
      category: category,
      notes: notes?.trim(),
      addedAt: addedAt ?? DateTime.now(),
      documents: documents,
    ));
  }

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final regNumber = json['regNumber'];
    if (id is! String || id.isEmpty) {
      throw const FormatException('VehicleModel.fromJson: "id" is missing or not a String.');
    }
    if (regNumber is! String || regNumber.isEmpty) {
      throw const FormatException('VehicleModel.fromJson: "regNumber" is missing or empty.');
    }
    return VehicleModel(
      id: id,
      regNumber: regNumber,
      make: json['make'] as String? ?? '',
      model: json['model'] as String? ?? '',
      year: json['year'] as String? ?? '',
      category: (json['category'] as String?) == 'Sell' ? VehicleCategory.sell : VehicleCategory.buy,
      notes: json['notes'] as String?,
      addedAt: DateTime.parse(json['addedAt'] as String),
      documents: (json['documents'] as List<dynamic>? ?? [])
          .map((d) => DocumentModel.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'regNumber': regNumber,
        'make': make,
        'model': model,
        'year': year,
        'category': category == VehicleCategory.sell ? 'Sell' : 'Buy',
        'notes': notes,
        'addedAt': addedAt.toIso8601String(),
        'documents': documents.map((d) => d.toJson()).toList(),
      };

  VehiclesCompanion toCompanion() {
    return VehiclesCompanion.insert(
      id: id,
      regNumber: regNumber,
      make: make,
      model: model,
      year: year,
      category: category == VehicleCategory.sell ? 'Sell' : 'Buy',
      addedAt: addedAt,
      notes: Value(notes),
    );
  }

  factory VehicleModel.fromDrift(Vehicle row, {List<DocumentModel> documents = const []}) {
    return VehicleModel(
      id: row.id,
      regNumber: row.regNumber,
      make: row.make,
      model: row.model,
      year: row.year,
      category: row.category == 'Sell' ? VehicleCategory.sell : VehicleCategory.buy,
      notes: row.notes,
      addedAt: row.addedAt,
      documents: documents,
    );
  }

  VehicleEntity toEntity() {
    return VehicleEntity(
      id: id,
      regNumber: regNumber,
      make: make,
      model: model,
      year: year,
      category: category,
      addedAt: addedAt,
      notes: notes,
      documents: documents.map((d) => d.toEntity()).toList(),
    );
  }
}
