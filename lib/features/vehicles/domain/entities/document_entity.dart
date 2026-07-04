/// A single document attached to a vehicle — the domain layer's plain
/// representation.
class DocumentEntity {
  const DocumentEntity({
    required this.id,
    required this.vehicleId,
    required this.type,
    required this.fileName,
    required this.filePath,
    required this.uploadedAt,
  });

  final String id;
  final String vehicleId;
  final String type;
  final String fileName;
  final String filePath;
  final DateTime uploadedAt;
}
