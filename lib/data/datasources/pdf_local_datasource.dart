import '../../domain/entities/compression_options.dart';
import '../../domain/entities/pdf_document.dart';
import '../../domain/entities/pdf_page.dart';

/// Abstract data source for PDF operations
/// This will be implemented with actual PDF libraries
abstract class PdfLocalDataSource {
  Future<PdfDocument> loadDocument(String filePath);
  Future<List<PdfPage>> getPages(String filePath);
  Future<PdfDocument> mergePdfs({
    required List<String> filePaths,
    required String outputPath,
    List<int>? pageRanges,
  });
  Future<List<PdfDocument>> splitPdf({
    required String filePath,
    required String outputDirectory,
    List<int>? pageNumbers,
    int? pagesPerFile,
  });
  Future<PdfDocument> extractPages({
    required String filePath,
    required String outputPath,
    required List<int> pageNumbers,
  });
  Future<PdfDocument> deletePages({
    required String filePath,
    required String outputPath,
    required List<int> pageNumbers,
  });
  Future<PdfDocument> rotatePages({
    required String filePath,
    required String outputPath,
    required Map<int, int> pageRotations,
  });
  Future<PdfDocument> compressPdf({
    required String filePath,
    required String outputPath,
    required CompressionOptions options,
  });
  Future<PdfDocument> protectPdf({
    required String filePath,
    required String outputPath,
    required String password,
    String? ownerPassword,
  });
  Future<PdfDocument> unlockPdf({
    required String filePath,
    required String outputPath,
    required String password,
  });
  Future<PdfDocument> addWatermark({
    required String filePath,
    required String outputPath,
    required String watermarkText,
    double opacity,
    List<int>? pageNumbers,
  });
  Future<PdfMetadata> getMetadata(String filePath);
  Future<PdfDocument> updateMetadata({
    required String filePath,
    required String outputPath,
    required PdfMetadata metadata,
  });
  Future<String> extractText(String filePath);
  Future<List<int>> searchText({
    required String filePath,
    required String searchQuery,
  });
  Future<PdfDocument> createPdfFromImages({
    required List<String> imagePaths,
    required String outputPath,
  });
}
