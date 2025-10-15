import 'package:equatable/equatable.dart';

/// Types of PDF operations
enum PdfOperationType {
  merge,
  split,
  compress,
  rotate,
  extract,
  delete,
  organize,
  watermark,
  protect,
  unlock,
  convert,
  ocr,
  sign,
  scan,
}

/// Represents a PDF operation with its parameters
class PdfOperation extends Equatable {
  final String id;
  final PdfOperationType type;
  final DateTime createdAt;
  final Map<String, dynamic> parameters;

  const PdfOperation({
    required this.id,
    required this.type,
    required this.createdAt,
    required this.parameters,
  });

  @override
  List<Object?> get props => [id, type, createdAt, parameters];
}

/// Operation result with progress tracking
class OperationProgress extends Equatable {
  final String operationId;
  final double progress; // 0.0 to 1.0
  final OperationStatus status;
  final String? message;
  final String? errorMessage;

  const OperationProgress({
    required this.operationId,
    required this.progress,
    required this.status,
    this.message,
    this.errorMessage,
  });

  /// Get progress percentage
  int get progressPercentage => (progress * 100).round();

  OperationProgress copyWith({
    String? operationId,
    double? progress,
    OperationStatus? status,
    String? message,
    String? errorMessage,
  }) {
    return OperationProgress(
      operationId: operationId ?? this.operationId,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      message: message ?? this.message,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        operationId,
        progress,
        status,
        message,
        errorMessage,
      ];
}

/// Operation status
enum OperationStatus {
  pending,
  inProgress,
  completed,
  failed,
  cancelled,
}
