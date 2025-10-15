import 'package:equatable/equatable.dart';

/// Represents a single page in a PDF document
class PdfPage extends Equatable {
  final int pageNumber;
  final double width;
  final double height;
  final int rotation; // 0, 90, 180, 270
  final String? thumbnailPath;

  const PdfPage({
    required this.pageNumber,
    required this.width,
    required this.height,
    this.rotation = 0,
    this.thumbnailPath,
  });

  /// Get aspect ratio
  double get aspectRatio => width / height;

  /// Check if page is landscape
  bool get isLandscape => width > height;

  /// Check if page is portrait
  bool get isPortrait => height > width;

  PdfPage copyWith({
    int? pageNumber,
    double? width,
    double? height,
    int? rotation,
    String? thumbnailPath,
  }) {
    return PdfPage(
      pageNumber: pageNumber ?? this.pageNumber,
      width: width ?? this.width,
      height: height ?? this.height,
      rotation: rotation ?? this.rotation,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }

  @override
  List<Object?> get props => [
        pageNumber,
        width,
        height,
        rotation,
        thumbnailPath,
      ];
}
