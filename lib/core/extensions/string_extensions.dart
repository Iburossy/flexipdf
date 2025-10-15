/// String utility extensions
extension StringExtensions on String {
  /// Get file extension
  String get fileExtension {
    final lastDot = lastIndexOf('.');
    if (lastDot == -1) return '';
    return substring(lastDot + 1).toLowerCase();
  }

  /// Get file name without extension
  String get fileNameWithoutExtension {
    final lastDot = lastIndexOf('.');
    final lastSlash = lastIndexOf('/');
    final start = lastSlash == -1 ? 0 : lastSlash + 1;
    final end = lastDot == -1 ? length : lastDot;
    return substring(start, end);
  }

  /// Get file name with extension
  String get fileName {
    final lastSlash = lastIndexOf('/');
    return lastSlash == -1 ? this : substring(lastSlash + 1);
  }

  /// Check if string is a valid PDF file
  bool get isPdf => fileExtension == 'pdf';

  /// Check if string is a valid image file
  bool get isImage {
    final ext = fileExtension;
    return ext == 'jpg' || ext == 'jpeg' || ext == 'png' || ext == 'tiff';
  }

  /// Check if string is a valid Office file
  bool get isOfficeDocument {
    final ext = fileExtension;
    return ext == 'docx' || ext == 'xlsx' || ext == 'pptx';
  }

  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Check if string is null or empty
  bool get isNullOrEmpty => isEmpty;

  /// Check if string is not null and not empty
  bool get isNotNullOrEmpty => isNotEmpty;
}
