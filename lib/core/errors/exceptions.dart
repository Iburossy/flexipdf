/// Base exception class
class AppException implements Exception {
  final String message;
  final String? code;

  AppException({
    required this.message,
    this.code,
  });

  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// File-related exceptions
class FileException extends AppException {
  FileException({
    required super.message,
    super.code,
  });
}

/// Permission-related exceptions
class PermissionException extends AppException {
  PermissionException({
    required super.message,
    super.code,
  });
}

/// PDF processing exceptions
class PdfProcessingException extends AppException {
  PdfProcessingException({
    required super.message,
    super.code,
  });
}

/// Storage exceptions
class StorageException extends AppException {
  StorageException({
    required super.message,
    super.code,
  });
}

/// OCR exceptions
class OcrException extends AppException {
  OcrException({
    required super.message,
    super.code,
  });
}

/// Conversion exceptions
class ConversionException extends AppException {
  ConversionException({
    required super.message,
    super.code,
  });
}

/// Encryption/Decryption exceptions
class CryptoException extends AppException {
  CryptoException({
    required super.message,
    super.code,
  });
}

/// Memory-related exceptions
class MemoryException extends AppException {
  MemoryException({
    required super.message,
    super.code,
  });
}
