import 'package:get_it/get_it.dart';
import '../../data/datasources/pdf_local_datasource.dart';
import '../../data/datasources/pdf_local_datasource_impl.dart';
import '../../data/repositories/pdf_repository_impl.dart';
import '../../data/repositories/storage_repository_impl.dart';
import '../../domain/repositories/pdf_repository.dart';
import '../../domain/repositories/storage_repository.dart';
import '../../domain/usecases/pdf/compress_pdf_usecase.dart';
import '../../domain/usecases/pdf/load_document_usecase.dart';
import '../../domain/usecases/pdf/merge_pdfs_usecase.dart';
import '../../domain/usecases/pdf/split_pdf_usecase.dart';
import '../../domain/usecases/pdf/create_pdf_from_images_usecase.dart';
import '../../domain/usecases/pdf/protect_pdf_usecase.dart';
import '../../presentation/bloc/pdf/pdf_bloc.dart';

final getIt = GetIt.instance;

/// Setup dependency injection
/// Call this in main() before runApp()
Future<void> setupDependencies() async {
  // Data sources
  getIt.registerLazySingleton<PdfLocalDataSource>(
    () => PdfLocalDataSourceImpl(),
  );

  // Repositories
  getIt.registerLazySingleton<PdfRepository>(
    () => PdfRepositoryImpl(
      localDataSource: getIt<PdfLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton<StorageRepository>(
    () => StorageRepositoryImpl(),
  );

  // Use cases - PDF
  getIt.registerLazySingleton(
    () => LoadDocumentUseCase(getIt<PdfRepository>()),
  );

  getIt.registerLazySingleton(
    () => MergePdfsUseCase(getIt<PdfRepository>()),
  );

  getIt.registerLazySingleton(
    () => SplitPdfUseCase(getIt<PdfRepository>()),
  );

  getIt.registerLazySingleton(
    () => CompressPdfUseCase(getIt<PdfRepository>()),
  );

  getIt.registerLazySingleton(
    () => CreatePdfFromImagesUseCase(getIt<PdfRepository>()),
  );

  getIt.registerLazySingleton(
    () => ProtectPdfUseCase(getIt<PdfRepository>()),
  );

  // BLoCs - Use factory for new instances each time
  getIt.registerFactory(
    () => PdfBloc(
      loadDocumentUseCase: getIt<LoadDocumentUseCase>(),
      mergePdfsUseCase: getIt<MergePdfsUseCase>(),
      splitPdfUseCase: getIt<SplitPdfUseCase>(),
      compressPdfUseCase: getIt<CompressPdfUseCase>(),
    ),
  );
}

/// Reset all dependencies (useful for testing)
Future<void> resetDependencies() async {
  await getIt.reset();
}
