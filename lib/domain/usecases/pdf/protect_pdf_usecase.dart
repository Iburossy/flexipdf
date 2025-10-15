import 'package:equatable/equatable.dart';
import '../../entities/pdf_document.dart';
import '../../repositories/pdf_repository.dart';
import '../usecase.dart';
import '../../../core/utils/result.dart';

class ProtectPdfUseCase implements UseCase<PdfDocument, ProtectPdfParams> {
  final PdfRepository repository;

  ProtectPdfUseCase(this.repository);

  @override
  Future<Result<PdfDocument>> call(ProtectPdfParams params) async {
    return await repository.protectPdf(
      filePath: params.filePath,
      outputPath: params.outputPath,
      password: params.password,
      ownerPassword: params.ownerPassword,
    );
  }
}

class ProtectPdfParams extends Equatable {
  final String filePath;
  final String outputPath;
  final String password;
  final String? ownerPassword;

  const ProtectPdfParams({
    required this.filePath,
    required this.outputPath,
    required this.password,
    this.ownerPassword,
  });

  @override
  List<Object?> get props => [filePath, outputPath, password, ownerPassword];
}
