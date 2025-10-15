import '../../domain/entities/pdf_page.dart';

/// Data model for PDF page
class PdfPageModel extends PdfPage {
  const PdfPageModel({
    required super.pageNumber,
    required super.width,
    required super.height,
    super.rotation,
    super.thumbnailPath,
  });

  /// Create from domain entity
  factory PdfPageModel.fromEntity(PdfPage entity) {
    return PdfPageModel(
      pageNumber: entity.pageNumber,
      width: entity.width,
      height: entity.height,
      rotation: entity.rotation,
      thumbnailPath: entity.thumbnailPath,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'pageNumber': pageNumber,
      'width': width,
      'height': height,
      'rotation': rotation,
      'thumbnailPath': thumbnailPath,
    };
  }

  /// Create from JSON
  factory PdfPageModel.fromJson(Map<String, dynamic> json) {
    return PdfPageModel(
      pageNumber: json['pageNumber'] as int,
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      rotation: json['rotation'] as int? ?? 0,
      thumbnailPath: json['thumbnailPath'] as String?,
    );
  }

  /// Convert to domain entity
  PdfPage toEntity() => this;
}
