import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/storage/app_database.dart' show Document, DocumentsCompanion;
import '../../domain/entities/document_entity.dart';

enum DocumentKind { registrationCertificate, other }

extension on DocumentKind {
  String get label => switch (this) {
        DocumentKind.registrationCertificate => 'Registration Certificate',
        DocumentKind.other => 'Other',
      };
}

/// Serializable, validated representation of a document attached to a
/// vehicle. Every field is required — a document record with no file
/// behind it is meaningless.
class DocumentModel {
  const DocumentModel({
    required this.id,
    required this.vehicleId,
    required this.type,
    required this.fileName,
    required this.filePath,
    required this.uploadedAt,
  });

  final String id;
  final String vehicleId;
  final DocumentKind type;
  final String fileName;
  final String filePath;
  final DateTime uploadedAt;

  static Result<DocumentModel> create({
    required String id,
    required String vehicleId,
    required DocumentKind type,
    required String fileName,
    required String filePath,
    DateTime? uploadedAt,
  }) {
    if (fileName.trim().isEmpty) {
      return const Failed(ValidationFailure('Document file name cannot be empty.'));
    }
    if (filePath.trim().isEmpty) {
      return const Failed(ValidationFailure('Document has no file attached.'));
    }
    return Success(DocumentModel(
      id: id,
      vehicleId: vehicleId,
      type: type,
      fileName: fileName.trim(),
      filePath: filePath.trim(),
      uploadedAt: uploadedAt ?? DateTime.now(),
    ));
  }

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final fileName = json['fileName'];
    final filePath = json['filePath'];
    if (id is! String || id.isEmpty) {
      throw const FormatException('DocumentModel.fromJson: "id" is missing or not a String.');
    }
    if (fileName is! String || fileName.isEmpty) {
      throw const FormatException('DocumentModel.fromJson: "fileName" is missing or empty.');
    }
    if (filePath is! String || filePath.isEmpty) {
      throw const FormatException('DocumentModel.fromJson: "filePath" is missing or empty.');
    }
    return DocumentModel(
      id: id,
      vehicleId: json['vehicleId'] as String,
      type: (json['type'] as String?) == 'Other' ? DocumentKind.other : DocumentKind.registrationCertificate,
      fileName: fileName,
      filePath: filePath,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicleId': vehicleId,
        'type': type.label,
        'fileName': fileName,
        'filePath': filePath,
        'uploadedAt': uploadedAt.toIso8601String(),
      };

  DocumentsCompanion toCompanion() {
    return DocumentsCompanion.insert(
      id: id,
      vehicleId: vehicleId,
      type: type.label,
      fileName: fileName,
      filePath: filePath,
      uploadedAt: uploadedAt,
    );
  }

  factory DocumentModel.fromDrift(Document row) {
    return DocumentModel(
      id: row.id,
      vehicleId: row.vehicleId,
      type: row.type == 'Other' ? DocumentKind.other : DocumentKind.registrationCertificate,
      fileName: row.fileName,
      filePath: row.filePath,
      uploadedAt: row.uploadedAt,
    );
  }

  DocumentEntity toEntity() {
    return DocumentEntity(id: id, vehicleId: vehicleId, type: type.label, fileName: fileName, filePath: filePath, uploadedAt: uploadedAt);
  }
}
