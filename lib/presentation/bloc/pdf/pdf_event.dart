import 'package:equatable/equatable.dart';
import '../../../domain/entities/compression_options.dart';

/// Base class for PDF events
abstract class PdfEvent extends Equatable {
  const PdfEvent();

  @override
  List<Object?> get props => [];
}

/// Load PDF document
class LoadPdfDocument extends PdfEvent {
  final String filePath;

  const LoadPdfDocument(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

/// Merge multiple PDFs
class MergePdfs extends PdfEvent {
  final List<String> filePaths;
  final String outputPath;

  const MergePdfs({
    required this.filePaths,
    required this.outputPath,
  });

  @override
  List<Object?> get props => [filePaths, outputPath];
}

/// Split PDF
class SplitPdf extends PdfEvent {
  final String filePath;
  final String outputDirectory;
  final List<int>? pageNumbers;
  final int? pagesPerFile;

  const SplitPdf({
    required this.filePath,
    required this.outputDirectory,
    this.pageNumbers,
    this.pagesPerFile,
  });

  @override
  List<Object?> get props => [filePath, outputDirectory, pageNumbers, pagesPerFile];
}

/// Compress PDF
class CompressPdf extends PdfEvent {
  final String filePath;
  final String outputPath;
  final CompressionOptions options;

  const CompressPdf({
    required this.filePath,
    required this.outputPath,
    required this.options,
  });

  @override
  List<Object?> get props => [filePath, outputPath, options];
}

/// Reset PDF state
class ResetPdfState extends PdfEvent {
  const ResetPdfState();
}
