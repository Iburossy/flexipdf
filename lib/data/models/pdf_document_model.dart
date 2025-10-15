import 'dart:io';
import '../../domain/entities/pdf_document.dart';

/// Data model for PDF document
/// Extends domain entity and adds serialization capabilities
class PdfDocumentModel extends PdfDocument {
  const PdfDocumentModel({
    required super.id,
    required super.name,
    required super.path,
    required super.sizeInBytes,
    required super.pageCount,
    required super.createdAt,
    required super.modifiedAt,
    super.isEncrypted,
    super.metadata,
  });

  /// Create from domain entity
  factory PdfDocumentModel.fromEntity(PdfDocument entity) {
    return PdfDocumentModel(
      id: entity.id,
      name: entity.name,
      path: entity.path,
      sizeInBytes: entity.sizeInBytes,
      pageCount: entity.pageCount,
      createdAt: entity.createdAt,
      modifiedAt: entity.modifiedAt,
      isEncrypted: entity.isEncrypted,
      metadata: entity.metadata,
    );
  }

  /// Create from file
  static Future<PdfDocumentModel> fromFile({
    required String id,
    required File file,
    required int pageCount,
    bool isEncrypted = false,
    PdfMetadata? metadata,
  }) async {
    final stat = await file.stat();
    
    return PdfDocumentModel(
      id: id,
      name: file.path.split('/').last,
      path: file.path,
      sizeInBytes: stat.size,
      pageCount: pageCount,
      createdAt: stat.changed,
      modifiedAt: stat.modified,
      isEncrypted: isEncrypted,
      metadata: metadata,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'sizeInBytes': sizeInBytes,
      'pageCount': pageCount,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'isEncrypted': isEncrypted,
      'metadata': metadata != null ? _metadataToJson(metadata!) : null,
    };
  }

  /// Create from JSON
  factory PdfDocumentModel.fromJson(Map<String, dynamic> json) {
    return PdfDocumentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      sizeInBytes: json['sizeInBytes'] as int,
      pageCount: json['pageCount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
      isEncrypted: json['isEncrypted'] as bool? ?? false,
      metadata: json['metadata'] != null
          ? _metadataFromJson(json['metadata'] as Map<String, dynamic>)
          : null,
    );
  }

  static Map<String, dynamic> _metadataToJson(PdfMetadata metadata) {
    return {
      'title': metadata.title,
      'author': metadata.author,
      'subject': metadata.subject,
      'keywords': metadata.keywords,
      'creator': metadata.creator,
      'producer': metadata.producer,
      'creationDate': metadata.creationDate?.toIso8601String(),
      'modificationDate': metadata.modificationDate?.toIso8601String(),
    };
  }

  static PdfMetadata _metadataFromJson(Map<String, dynamic> json) {
    return PdfMetadata(
      title: json['title'] as String?,
      author: json['author'] as String?,
      subject: json['subject'] as String?,
      keywords: json['keywords'] as String?,
      creator: json['creator'] as String?,
      producer: json['producer'] as String?,
      creationDate: json['creationDate'] != null
          ? DateTime.parse(json['creationDate'] as String)
          : null,
      modificationDate: json['modificationDate'] != null
          ? DateTime.parse(json['modificationDate'] as String)
          : null,
    );
  }

  /// Convert to domain entity
  PdfDocument toEntity() => this;
}
