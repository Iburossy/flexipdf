import 'package:equatable/equatable.dart';
import '../../entities/pdf_document.dart';
import '../../repositories/pdf_repository.dart';
import '../usecase.dart';
import '../../../core/utils/result.dart';

/// Use case for splitting a PDF file
class SplitPdfUseCase implements UseCase<List<PdfDocument>, SplitPdfParams> {
  final PdfRepository repository;

  SplitPdfUseCase(this.repository);

  @override
  Future<Result<List<PdfDocument>>> call(SplitPdfParams params) async {
    return await repository.splitPdf(
      filePath: params.filePath,
      outputDirectory: params.outputDirectory,
      pageNumbers: params.pageNumbers,
      pagesPerFile: params.pagesPerFile,
    );
  }
}

/// Parameters for split PDF use case
class SplitPdfParams extends Equatable {
  final String filePath;
  final String outputDirectory;
  final List<int>? pageNumbers;
  final int? pagesPerFile;

  const SplitPdfParams({
    required this.filePath,
    required this.outputDirectory,
    this.pageNumbers,
    this.pagesPerFile,
  });

  @override
  List<Object?> get props => [
        filePath,
        outputDirectory,
        pageNumbers,
        pagesPerFile,
      ];
}
