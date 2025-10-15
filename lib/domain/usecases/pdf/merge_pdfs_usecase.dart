import 'package:equatable/equatable.dart';
import '../../entities/pdf_document.dart';
import '../../repositories/pdf_repository.dart';
import '../usecase.dart';
import '../../../core/utils/result.dart';

/// Use case for merging multiple PDF files
class MergePdfsUseCase implements UseCase<PdfDocument, MergePdfsParams> {
  final PdfRepository repository;

  MergePdfsUseCase(this.repository);

  @override
  Future<Result<PdfDocument>> call(MergePdfsParams params) async {
    return await repository.mergePdfs(
      filePaths: params.filePaths,
      outputPath: params.outputPath,
      pageRanges: params.pageRanges,
    );
  }
}

/// Parameters for merge PDFs use case
class MergePdfsParams extends Equatable {
  final List<String> filePaths;
  final String outputPath;
  final List<int>? pageRanges;

  const MergePdfsParams({
    required this.filePaths,
    required this.outputPath,
    this.pageRanges,
  });

  @override
  List<Object?> get props => [filePaths, outputPath, pageRanges];
}
