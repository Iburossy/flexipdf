import 'package:equatable/equatable.dart';
import '../../entities/compression_options.dart';
import '../../entities/pdf_document.dart';
import '../../repositories/pdf_repository.dart';
import '../usecase.dart';
import '../../../core/utils/result.dart';

/// Use case for compressing a PDF file
class CompressPdfUseCase implements UseCase<PdfDocument, CompressPdfParams> {
  final PdfRepository repository;

  CompressPdfUseCase(this.repository);

  @override
  Future<Result<PdfDocument>> call(CompressPdfParams params) async {
    return await repository.compressPdf(
      filePath: params.filePath,
      outputPath: params.outputPath,
      options: params.options,
    );
  }
}

/// Parameters for compress PDF use case
class CompressPdfParams extends Equatable {
  final String filePath;
  final String outputPath;
  final CompressionOptions options;

  const CompressPdfParams({
    required this.filePath,
    required this.outputPath,
    required this.options,
  });

  @override
  List<Object?> get props => [filePath, outputPath, options];
}
