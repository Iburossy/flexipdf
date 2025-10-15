import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/usecases/pdf/compress_pdf_usecase.dart';
import '../../../domain/usecases/pdf/load_document_usecase.dart';
import '../../../domain/usecases/pdf/merge_pdfs_usecase.dart';
import '../../../domain/usecases/pdf/split_pdf_usecase.dart';
import 'pdf_event.dart';
import 'pdf_state.dart';

/// BLoC for PDF operations
class PdfBloc extends Bloc<PdfEvent, PdfState> {
  final LoadDocumentUseCase loadDocumentUseCase;
  final MergePdfsUseCase mergePdfsUseCase;
  final SplitPdfUseCase splitPdfUseCase;
  final CompressPdfUseCase compressPdfUseCase;
  final Logger _logger = Logger('PdfBloc');

  PdfBloc({
    required this.loadDocumentUseCase,
    required this.mergePdfsUseCase,
    required this.splitPdfUseCase,
    required this.compressPdfUseCase,
  }) : super(const PdfInitial()) {
    on<LoadPdfDocument>(_onLoadPdfDocument);
    on<MergePdfs>(_onMergePdfs);
    on<SplitPdf>(_onSplitPdf);
    on<CompressPdf>(_onCompressPdf);
    on<ResetPdfState>(_onResetPdfState);
  }

  Future<void> _onLoadPdfDocument(
    LoadPdfDocument event,
    Emitter<PdfState> emit,
  ) async {
    try {
      _logger.info('Loading PDF document: ${event.filePath}');
      emit(const PdfLoading(message: 'Loading document...'));

      final result = await loadDocumentUseCase(
        LoadDocumentParams(filePath: event.filePath),
      );

      result.fold(
        onSuccess: (document) {
          _logger.info('Document loaded successfully: ${document.name}');
          emit(PdfDocumentLoaded(document));
        },
        onFailure: (failure) {
          _logger.error('Failed to load document: ${failure.message}');
          emit(PdfError(
            message: failure.message,
            code: failure.code,
          ));
        },
      );
    } catch (e, stackTrace) {
      _logger.error('Unexpected error loading document', e, stackTrace);
      emit(PdfError(message: 'Unexpected error: $e'));
    }
  }

  Future<void> _onMergePdfs(
    MergePdfs event,
    Emitter<PdfState> emit,
  ) async {
    try {
      _logger.info('Merging ${event.filePaths.length} PDFs');
      emit(const PdfLoading(message: 'Merging PDFs...', progress: 0.0));

      final result = await mergePdfsUseCase(
        MergePdfsParams(
          filePaths: event.filePaths,
          outputPath: event.outputPath,
        ),
      );

      result.fold(
        onSuccess: (document) {
          _logger.info('PDFs merged successfully');
          emit(PdfOperationSuccess(
            message: 'PDFs merged successfully',
            document: document,
          ));
        },
        onFailure: (failure) {
          _logger.error('Failed to merge PDFs: ${failure.message}');
          emit(PdfError(
            message: failure.message,
            code: failure.code,
          ));
        },
      );
    } catch (e, stackTrace) {
      _logger.error('Unexpected error merging PDFs', e, stackTrace);
      emit(PdfError(message: 'Unexpected error: $e'));
    }
  }

  Future<void> _onSplitPdf(
    SplitPdf event,
    Emitter<PdfState> emit,
  ) async {
    try {
      _logger.info('Splitting PDF: ${event.filePath}');
      emit(const PdfLoading(message: 'Splitting PDF...', progress: 0.0));

      final result = await splitPdfUseCase(
        SplitPdfParams(
          filePath: event.filePath,
          outputDirectory: event.outputDirectory,
          pageNumbers: event.pageNumbers,
          pagesPerFile: event.pagesPerFile,
        ),
      );

      result.fold(
        onSuccess: (documents) {
          _logger.info('PDF split successfully into ${documents.length} files');
          emit(PdfDocumentsLoaded(documents));
        },
        onFailure: (failure) {
          _logger.error('Failed to split PDF: ${failure.message}');
          emit(PdfError(
            message: failure.message,
            code: failure.code,
          ));
        },
      );
    } catch (e, stackTrace) {
      _logger.error('Unexpected error splitting PDF', e, stackTrace);
      emit(PdfError(message: 'Unexpected error: $e'));
    }
  }

  Future<void> _onCompressPdf(
    CompressPdf event,
    Emitter<PdfState> emit,
  ) async {
    try {
      _logger.info('Compressing PDF: ${event.filePath}');
      emit(const PdfLoading(message: 'Compressing PDF...', progress: 0.0));

      final result = await compressPdfUseCase(
        CompressPdfParams(
          filePath: event.filePath,
          outputPath: event.outputPath,
          options: event.options,
        ),
      );

      result.fold(
        onSuccess: (document) {
          _logger.info('PDF compressed successfully');
          emit(PdfOperationSuccess(
            message: 'PDF compressed successfully',
            document: document,
          ));
        },
        onFailure: (failure) {
          _logger.error('Failed to compress PDF: ${failure.message}');
          emit(PdfError(
            message: failure.message,
            code: failure.code,
          ));
        },
      );
    } catch (e, stackTrace) {
      _logger.error('Unexpected error compressing PDF', e, stackTrace);
      emit(PdfError(message: 'Unexpected error: $e'));
    }
  }

  Future<void> _onResetPdfState(
    ResetPdfState event,
    Emitter<PdfState> emit,
  ) async {
    _logger.info('Resetting PDF state');
    emit(const PdfInitial());
  }
}
