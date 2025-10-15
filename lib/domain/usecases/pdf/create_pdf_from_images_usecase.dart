import 'package:equatable/equatable.dart';
import '../../entities/pdf_document.dart';
import '../../repositories/pdf_repository.dart';
import '../usecase.dart';
import '../../../core/utils/result.dart';

/// Use case for creating PDF from images
class CreatePdfFromImagesUseCase implements UseCase<PdfDocument, CreatePdfFromImagesParams> {
  final PdfRepository repository;

  CreatePdfFromImagesUseCase(this.repository);

  @override
  Future<Result<PdfDocument>> call(CreatePdfFromImagesParams params) async {
    return await repository.createPdfFromImages(
      imagePaths: params.imagePaths,
      outputPath: params.outputPath,
    );
  }
}

/// Parameters for create PDF from images use case
class CreatePdfFromImagesParams extends Equatable {
  final List<String> imagePaths;
  final String outputPath;

  const CreatePdfFromImagesParams({
    required this.imagePaths,
    required this.outputPath,
  });

  @override
  List<Object?> get props => [imagePaths, outputPath];
}
