import 'package:equatable/equatable.dart';

/// Compression level enum
enum CompressionLevel {
  low,
  medium,
  high,
}

/// Options for PDF compression
class CompressionOptions extends Equatable {
  final CompressionLevel level;
  final bool optimizeImages;
  final bool removeMetadata;
  final bool linearize;
  final int? imageQuality; // 1-100

  const CompressionOptions({
    required this.level,
    this.optimizeImages = true,
    this.removeMetadata = false,
    this.linearize = true,
    this.imageQuality,
  });

  /// Get default compression options
  factory CompressionOptions.defaultOptions() {
    return const CompressionOptions(
      level: CompressionLevel.medium,
      optimizeImages: true,
      removeMetadata: false,
      linearize: true,
      imageQuality: 75,
    );
  }

  /// Get low compression options
  factory CompressionOptions.low() {
    return const CompressionOptions(
      level: CompressionLevel.low,
      optimizeImages: true,
      removeMetadata: false,
      linearize: true,
      imageQuality: 90,
    );
  }

  /// Get high compression options
  factory CompressionOptions.high() {
    return const CompressionOptions(
      level: CompressionLevel.high,
      optimizeImages: true,
      removeMetadata: true,
      linearize: true,
      imageQuality: 50,
    );
  }

  CompressionOptions copyWith({
    CompressionLevel? level,
    bool? optimizeImages,
    bool? removeMetadata,
    bool? linearize,
    int? imageQuality,
  }) {
    return CompressionOptions(
      level: level ?? this.level,
      optimizeImages: optimizeImages ?? this.optimizeImages,
      removeMetadata: removeMetadata ?? this.removeMetadata,
      linearize: linearize ?? this.linearize,
      imageQuality: imageQuality ?? this.imageQuality,
    );
  }

  @override
  List<Object?> get props => [
        level,
        optimizeImages,
        removeMetadata,
        linearize,
        imageQuality,
      ];
}
