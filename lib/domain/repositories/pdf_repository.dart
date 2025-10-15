import '../entities/compression_options.dart';
import '../entities/pdf_document.dart';
import '../entities/pdf_page.dart';
import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';

/// Abstract repository for PDF operations
/// This defines the contract that data layer must implement
abstract class PdfRepository {
  /// Load a PDF document from file path
  Future<Result<PdfDocument>> loadDocument(String filePath);

  /// Get pages from a PDF document
  Future<Result<List<PdfPage>>> getPages(String filePath);

  /// Merge multiple PDFs into one
  Future<Result<PdfDocument>> mergePdfs({
    required List<String> filePaths,
    required String outputPath,
    List<int>? pageRanges,
  });

  /// Split a PDF into multiple files
  Future<Result<List<PdfDocument>>> splitPdf({
    required String filePath,
    required String outputDirectory,
    List<int>? pageNumbers,
    int? pagesPerFile,
  });

  /// Extract specific pages from a PDF
  Future<Result<PdfDocument>> extractPages({
    required String filePath,
    required String outputPath,
    required List<int> pageNumbers,
  });

  /// Delete specific pages from a PDF
  Future<Result<PdfDocument>> deletePages({
    required String filePath,
    required String outputPath,
    required List<int> pageNumbers,
  });

  /// Rotate pages in a PDF
  Future<Result<PdfDocument>> rotatePages({
    required String filePath,
    required String outputPath,
    required Map<int, int> pageRotations, // page number -> rotation degrees
  });

  /// Compress a PDF
  Future<Result<PdfDocument>> compressPdf({
    required String filePath,
    required String outputPath,
    required CompressionOptions options,
  });

  /// Protect PDF with password
  Future<Result<PdfDocument>> protectPdf({
    required String filePath,
    required String outputPath,
    required String password,
    String? ownerPassword,
  });

  /// Unlock protected PDF
  Future<Result<PdfDocument>> unlockPdf({
    required String filePath,
    required String outputPath,
    required String password,
  });

  /// Add watermark to PDF
  Future<Result<PdfDocument>> addWatermark({
    required String filePath,
    required String outputPath,
    required String watermarkText,
    double opacity = 0.5,
    List<int>? pageNumbers,
  });

  /// Get PDF metadata
  Future<Result<PdfMetadata>> getMetadata(String filePath);

  /// Update PDF metadata
  Future<Result<PdfDocument>> updateMetadata({
    required String filePath,
    required String outputPath,
    required PdfMetadata metadata,
  });

  /// Extract text from PDF
  Future<Result<String>> extractText(String filePath);

  /// Search text in PDF
  Future<Result<List<int>>> searchText({
    required String filePath,
    required String searchQuery,
  });

  /// Create PDF from images
  Future<Result<PdfDocument>> createPdfFromImages({
    required List<String> imagePaths,
    required String outputPath,
  });
}
