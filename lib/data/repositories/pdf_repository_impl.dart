import '../../domain/entities/compression_options.dart';
import '../../domain/entities/pdf_document.dart';
import '../../domain/entities/pdf_page.dart';
import '../../domain/repositories/pdf_repository.dart';
import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/logger.dart';
import '../datasources/pdf_local_datasource.dart';

/// Implementation of PDF repository
class PdfRepositoryImpl implements PdfRepository {
  final PdfLocalDataSource localDataSource;
  final Logger _logger = Logger('PdfRepositoryImpl');

  PdfRepositoryImpl({required this.localDataSource});

  @override
  Future<Result<PdfDocument>> loadDocument(String filePath) async {
    try {
      _logger.info('Loading document: $filePath');
      final document = await localDataSource.loadDocument(filePath);
      return Success(document);
    } on FileException catch (e) {
      _logger.error('File error loading document', e);
      return ResultFailure(FileFailure(message: e.message, code: e.code));
    } on PdfProcessingException catch (e) {
      _logger.error('PDF processing error', e);
      return ResultFailure(PdfProcessingFailure(message: e.message, code: e.code));
    } catch (e, stackTrace) {
      _logger.error('Unexpected error loading document', e, stackTrace);
      return ResultFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<PdfPage>>> getPages(String filePath) async {
    try {
      _logger.info('Getting pages from: $filePath');
      final pages = await localDataSource.getPages(filePath);
      return Success(pages);
    } on FileException catch (e) {
      return ResultFailure(FileFailure(message: e.message, code: e.code));
    } on PdfProcessingException catch (e) {
      return ResultFailure(PdfProcessingFailure(message: e.message, code: e.code));
    } catch (e, stackTrace) {
      _logger.error('Unexpected error getting pages', e, stackTrace);
      return ResultFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<PdfDocument>> mergePdfs({
    required List<String> filePaths,
    required String outputPath,
    List<int>? pageRanges,
  }) async {
    try {
      _logger.info('Merging ${filePaths.length} PDFs');
      final document = await localDataSource.mergePdfs(
        filePaths: filePaths,
        outputPath: outputPath,
        pageRanges: pageRanges,
      );
      return Success(document);
    } on FileException catch (e) {
      return ResultFailure(FileFailure(message: e.message, code: e.code));
    } on PdfProcessingException catch (e) {
      return ResultFailure(PdfProcessingFailure(message: e.message, code: e.code));
    } catch (e, stackTrace) {
      _logger.error('Unexpected error merging PDFs', e, stackTrace);
      return ResultFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<PdfDocument>>> splitPdf({
    required String filePath,
    required String outputDirectory,
    List<int>? pageNumbers,
    int? pagesPerFile,
  }) async {
    try {
      _logger.info('Splitting PDF: $filePath');
      final documents = await localDataSource.splitPdf(
        filePath: filePath,
        outputDirectory: outputDirectory,
        pageNumbers: pageNumbers,
        pagesPerFile: pagesPerFile,
      );
      return Success(documents);
    } on FileException catch (e) {
      return ResultFailure(FileFailure(message: e.message, code: e.code));
    } on PdfProcessingException catch (e) {
      return ResultFailure(PdfProcessingFailure(message: e.message, code: e.code));
    } catch (e, stackTrace) {
      _logger.error('Unexpected error splitting PDF', e, stackTrace);
      return ResultFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<PdfDocument>> extractPages({
    required String filePath,
    required String outputPath,
    required List<int> pageNumbers,
  }) async {
    try {
      _logger.info('Extracting pages from: $filePath');
      final document = await localDataSource.extractPages(
        filePath: filePath,
        outputPath: outputPath,
        pageNumbers: pageNumbers,
      );
      return Success(document);
    } on FileException catch (e) {
      return ResultFailure(FileFailure(message: e.message, code: e.code));
    } on PdfProcessingException catch (e) {
      return ResultFailure(PdfProcessingFailure(message: e.message, code: e.code));
    } catch (e, stackTrace) {
      _logger.error('Unexpected error extracting pages', e, stackTrace);
      return ResultFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<PdfDocument>> deletePages({
    required String filePath,
    required String outputPath,
    required List<int> pageNumbers,
  }) async {
    try {
      _logger.info('Deleting pages from: $filePath');
      final document = await localDataSource.deletePages(
        filePath: filePath,
        outputPath: outputPath,
        pageNumbers: pageNumbers,
      );
      return Success(document);
    } on FileException catch (e) {
      return ResultFailure(FileFailure(message: e.message, code: e.code));
    } on PdfProcessingException catch (e) {
      return ResultFailure(PdfProcessingFailure(message: e.message, code: e.code));
    } catch (e, stackTrace) {
      _logger.error('Unexpected error deleting pages', e, stackTrace);
      return ResultFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<PdfDocument>> rotatePages({
    required String filePath,
    required String outputPath,
    required Map<int, int> pageRotations,
  }) async {
    try {
      _logger.info('Rotating pages in: $filePath');
      final document = await localDataSource.rotatePages(
        filePath: filePath,
        outputPath: outputPath,
        pageRotations: pageRotations,
      );
      return Success(document);
    } on FileException catch (e) {
      return ResultFailure(FileFailure(message: e.message, code: e.code));
    } on PdfProcessingException catch (e) {
      return ResultFailure(PdfProcessingFailure(message: e.message, code: e.code));
    } catch (e, stackTrace) {
      _logger.error('Unexpected error rotating pages', e, stackTrace);
      return ResultFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<PdfDocument>> compressPdf({
    required String filePath,
    required String outputPath,
    required CompressionOptions options,
  }) async {
    try {
      _logger.info('Compressing PDF: $filePath');
      final document = await localDataSource.compressPdf(
        filePath: filePath,
        outputPath: outputPath,
        options: options,
      );
      return Success(document);
    } on FileException catch (e) {
      return ResultFailure(FileFailure(message: e.message, code: e.code));
    } on PdfProcessingException catch (e) {
      return ResultFailure(PdfProcessingFailure(message: e.message, code: e.code));
    } catch (e, stackTrace) {
      _logger.error('Unexpected error compressing PDF', e, stackTrace);
      return ResultFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<PdfDocument>> protectPdf({
    required String filePath,
    required String outputPath,
    required String password,
    String? ownerPassword,
  }) async {
    try {
      _logger.info('Protecting PDF: $filePath');
      final document = await localDataSource.protectPdf(
        filePath: filePath,
        outputPath: outputPath,
        password: password,
        ownerPassword: ownerPassword,
      );
      return Success(document);
    } on FileException catch (e) {
      return ResultFailure(FileFailure(message: e.message, code: e.code));
    } on PdfProcessingException catch (e) {
      return ResultFailure(PdfProcessingFailure(message: e.message, code: e.code));
    } catch (e, stackTrace) {
      _logger.error('Unexpected error protecting PDF', e, stackTrace);
      return ResultFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<PdfDocument>> unlockPdf({
    required String filePath,
    required String outputPath,
    required String password,
  }) async {
    try {
      _logger.info('Unlocking PDF: $filePath');
      final document = await localDataSource.unlockPdf(
        filePath: filePath,
        outputPath: outputPath,
        password: password,
      );
      return Success(document);
    } on FileException catch (e) {
      return ResultFailure(FileFailure(message: e.message, code: e.code));
    } on PdfProcessingException catch (e) {
      return ResultFailure(PdfProcessingFailure(message: e.message, code: e.code));
    } catch (e, stackTrace) {
      _logger.error('Unexpected error unlocking PDF', e, stackTrace);
      return ResultFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<PdfDocument>> addWatermark({
    required String filePath,
    required String outputPath,
    required String watermarkText,
    double opacity = 0.5,
    List<int>? pageNumbers,
  }) async {
    try {
      _logger.info('Adding watermark to: $filePath');
      final document = await localDataSource.addWatermark(
        filePath: filePath,
        outputPath: outputPath,
        watermarkText: watermarkText,
        opacity: opacity,
        pageNumbers: pageNumbers,
      );
      return Success(document);
    } on FileException catch (e) {
      return ResultFailure(FileFailure(message: e.message, code: e.code));
    } on PdfProcessingException catch (e) {
      return ResultFailure(PdfProcessingFailure(message: e.message, code: e.code));
    } catch (e, stackTrace) {
      _logger.error('Unexpected error adding watermark', e, stackTrace);
      return ResultFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<PdfMetadata>> getMetadata(String filePath) async {
    try {
      _logger.info('Getting metadata from: $filePath');
      final metadata = await localDataSource.getMetadata(filePath);
      return Success(metadata);
    } on FileException catch (e) {
      return ResultFailure(FileFailure(message: e.message, code: e.code));
    } on PdfProcessingException catch (e) {
      return ResultFailure(PdfProcessingFailure(message: e.message, code: e.code));
    } catch (e, stackTrace) {
      _logger.error('Unexpected error getting metadata', e, stackTrace);
      return ResultFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<PdfDocument>> updateMetadata({
    required String filePath,
    required String outputPath,
    required PdfMetadata metadata,
  }) async {
    try {
      _logger.info('Updating metadata for: $filePath');
      final document = await localDataSource.updateMetadata(
        filePath: filePath,
        outputPath: outputPath,
        metadata: metadata,
      );
      return Success(document);
    } on FileException catch (e) {
      return ResultFailure(FileFailure(message: e.message, code: e.code));
    } on PdfProcessingException catch (e) {
      return ResultFailure(PdfProcessingFailure(message: e.message, code: e.code));
    } catch (e, stackTrace) {
      _logger.error('Unexpected error updating metadata', e, stackTrace);
      return ResultFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<String>> extractText(String filePath) async {
    try {
      _logger.info('Extracting text from: $filePath');
      final text = await localDataSource.extractText(filePath);
      return Success(text);
    } on FileException catch (e) {
      return ResultFailure(FileFailure(message: e.message, code: e.code));
    } on PdfProcessingException catch (e) {
      return ResultFailure(PdfProcessingFailure(message: e.message, code: e.code));
    } catch (e, stackTrace) {
      _logger.error('Unexpected error extracting text', e, stackTrace);
      return ResultFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<int>>> searchText({
    required String filePath,
    required String searchQuery,
  }) async {
    try {
      _logger.info('Searching text in: $filePath');
      final pageNumbers = await localDataSource.searchText(
        filePath: filePath,
        searchQuery: searchQuery,
      );
      return Success(pageNumbers);
    } on FileException catch (e) {
      return ResultFailure(FileFailure(message: e.message, code: e.code));
    } on PdfProcessingException catch (e) {
      return ResultFailure(PdfProcessingFailure(message: e.message, code: e.code));
    } catch (e, stackTrace) {
      _logger.error('Unexpected error searching text', e, stackTrace);
      return ResultFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<PdfDocument>> createPdfFromImages({
    required List<String> imagePaths,
    required String outputPath,
  }) async {
    try {
      _logger.info('Creating PDF from images');
      final document = await localDataSource.createPdfFromImages(
        imagePaths: imagePaths,
        outputPath: outputPath,
      );
      return Success(document);
    } on FileException catch (e) {
      return ResultFailure(FileFailure(message: e.message, code: e.code));
    } on PdfProcessingException catch (e) {
      return ResultFailure(PdfProcessingFailure(message: e.message, code: e.code));
    } catch (e, stackTrace) {
      _logger.error('Unexpected error creating PDF from images', e, stackTrace);
      return ResultFailure(UnexpectedFailure(message: e.toString()));
    }
  }
}
