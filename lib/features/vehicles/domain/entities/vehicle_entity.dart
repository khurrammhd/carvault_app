import 'document_entity.dart';

enum VehicleCategory { buy, sell }

/// A vehicle and its attached documents — the domain layer's plain,
/// storage-agnostic representation.
class VehicleEntity {
  const VehicleEntity({
    required this.id,
    required this.regNumber,
    required this.make,
    required this.model,
    required this.year,
    required this.category,
    required this.addedAt,
    required this.documents,
    this.notes,
  });

  final String id;
  final String regNumber;
  final String make;
  final String model;
  final String year;
  final VehicleCategory category;
  final DateTime addedAt;
  final String? notes;
  final List<DocumentEntity> documents;

  int get documentCount => documents.length;
}
