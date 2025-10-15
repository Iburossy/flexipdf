import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
/// Using Equatable for value comparison
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

/// File-related failures
class FileFailure extends Failure {
  const FileFailure({
    required super.message,
    super.code,
  });
}

/// Permission-related failures
class PermissionFailure extends Failure {
  const PermissionFailure({
    required super.message,
    super.code,
  });
}

/// PDF processing failures
class PdfProcessingFailure extends Failure {
  const PdfProcessingFailure({
    required super.message,
    super.code,
  });
}

/// Storage failures
class StorageFailure extends Failure {
  const StorageFailure({
    required super.message,
    super.code,
  });
}

/// OCR failures
class OcrFailure extends Failure {
  const OcrFailure({
    required super.message,
    super.code,
  });
}

/// Conversion failures
class ConversionFailure extends Failure {
  const ConversionFailure({
    required super.message,
    super.code,
  });
}

/// Encryption/Decryption failures
class CryptoFailure extends Failure {
  const CryptoFailure({
    required super.message,
    super.code,
  });
}

/// Memory-related failures
class MemoryFailure extends Failure {
  const MemoryFailure({
    required super.message,
    super.code,
  });
}

/// Generic unexpected failure
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    required super.message,
    super.code,
  });
}
