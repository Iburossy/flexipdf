import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';

/// Abstract repository for file storage operations
abstract class StorageRepository {
  /// Get application documents directory
  Future<Result<String>> getDocumentsDirectory();

  /// Get temporary directory
  Future<Result<String>> getTempDirectory();

  /// Get export directory
  Future<Result<String>> getExportDirectory();

  /// Get public download directory (FlexiPDF folder)
  Future<Result<String>> getDownloadDirectory();

  /// Save file to storage
  Future<Result<String>> saveFile({
    required String sourcePath,
    required String destinationPath,
  });

  /// Copy file
  Future<Result<String>> copyFile({
    required String sourcePath,
    required String destinationPath,
  });

  /// Move file
  Future<Result<String>> moveFile({
    required String sourcePath,
    required String destinationPath,
  });

  /// Delete file
  Future<Result<void>> deleteFile(String filePath);

  /// Check if file exists
  Future<Result<bool>> fileExists(String filePath);

  /// Get file size
  Future<Result<int>> getFileSize(String filePath);

  /// List files in directory
  Future<Result<List<String>>> listFiles(String directoryPath);

  /// Create directory
  Future<Result<String>> createDirectory(String path);

  /// Delete directory
  Future<Result<void>> deleteDirectory(String path);

  /// Clean temporary files
  Future<Result<void>> cleanTempFiles();

  /// Get available storage space
  Future<Result<int>> getAvailableSpace();
}
