import 'package:equatable/equatable.dart';
import '../../entities/pdf_document.dart';
import '../../repositories/pdf_repository.dart';
import '../usecase.dart';
import '../../../core/utils/result.dart';

/// Use case for loading a PDF document
class LoadDocumentUseCase implements UseCase<PdfDocument, LoadDocumentParams> {
  final PdfRepository repository;

  LoadDocumentUseCase(this.repository);

  @override
  Future<Result<PdfDocument>> call(LoadDocumentParams params) async {
    return await repository.loadDocument(params.filePath);
  }
}

/// Parameters for load document use case
class LoadDocumentParams extends Equatable {
  final String filePath;

  const LoadDocumentParams({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}
