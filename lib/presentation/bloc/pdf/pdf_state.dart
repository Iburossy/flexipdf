import 'package:equatable/equatable.dart';
import '../../../domain/entities/pdf_document.dart';

/// Base class for PDF states
abstract class PdfState extends Equatable {
  const PdfState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class PdfInitial extends PdfState {
  const PdfInitial();
}

/// Loading state
class PdfLoading extends PdfState {
  final String? message;
  final double? progress; // 0.0 to 1.0

  const PdfLoading({this.message, this.progress});

  @override
  List<Object?> get props => [message, progress];
}

/// Document loaded successfully
class PdfDocumentLoaded extends PdfState {
  final PdfDocument document;

  const PdfDocumentLoaded(this.document);

  @override
  List<Object?> get props => [document];
}

/// Multiple documents loaded (for split operation)
class PdfDocumentsLoaded extends PdfState {
  final List<PdfDocument> documents;

  const PdfDocumentsLoaded(this.documents);

  @override
  List<Object?> get props => [documents];
}

/// Operation completed successfully
class PdfOperationSuccess extends PdfState {
  final String message;
  final PdfDocument? document;

  const PdfOperationSuccess({
    required this.message,
    this.document,
  });

  @override
  List<Object?> get props => [message, document];
}

/// Error state
class PdfError extends PdfState {
  final String message;
  final String? code;

  const PdfError({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}
