import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/result.dart';
import '../../domain/repositories/storage_repository.dart';

/// Implementation of storage repository
class StorageRepositoryImpl implements StorageRepository {
  final Logger _logger = Logger('StorageRepositoryImpl');

  @override
  Future<Result<String>> getDocumentsDirectory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      return Success(directory.path);
    } catch (e, stackTrace) {
      _logger.error('Error getting documents directory', e, stackTrace);
      return ResultFailure(
        StorageFailure(message: 'Failed to get documents directory: $e'),
      );
    }
  }

  @override
  Future<Result<String>> getTempDirectory() async {
    try {
      final directory = await getTemporaryDirectory();
      final tempPath = path.join(directory.path, AppConstants.tempFolderName);
      
      final tempDir = Directory(tempPath);
      if (!await tempDir.exists()) {
        await tempDir.create(recursive: true);
      }
      
      return Success(tempPath);
    } catch (e, stackTrace) {
      _logger.error('Error getting temp directory', e, stackTrace);
      return ResultFailure(
        StorageFailure(message: 'Failed to get temp directory: $e'),
      );
    }
  }

  @override
  Future<Result<String>> getExportDirectory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final exportPath = path.join(directory.path, AppConstants.exportFolderName);
      
      final exportDir = Directory(exportPath);
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }
      
      return Success(exportPath);
    } catch (e, stackTrace) {
      _logger.error('Error getting export directory', e, stackTrace);
      return ResultFailure(
        StorageFailure(message: 'Failed to get export directory: $e'),
      );
    }
  }

  @override
  Future<Result<String>> getDownloadDirectory() async {
    try {
      // Use external storage directory (accessible via file manager)
      final externalDir = await getExternalStorageDirectory();
      
      if (externalDir == null) {
        return ResultFailure(
          StorageFailure(message: 'External storage not available'),
        );
      }

      // Navigate to public Download folder
      // /storage/emulated/0/Android/data/com.app/files -> /storage/emulated/0/Download
      final publicPath = externalDir.path
          .replaceAll(RegExp(r'/Android/data/[^/]+/files'), '/Download');
      
      final flexiPdfPath = path.join(publicPath, AppConstants.downloadFolderName);
      final downloadDir = Directory(flexiPdfPath);
      
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      _logger.info('Using download directory: $flexiPdfPath');
      return Success(flexiPdfPath);
    } catch (e, stackTrace) {
      _logger.error('Error getting download directory', e, stackTrace);
      return ResultFailure(
        StorageFailure(message: 'Failed to get download directory: $e'),
      );
    }
  }

  @override
  Future<Result<String>> saveFile({
    required String sourcePath,
    required String destinationPath,
  }) async {
    try {
      _logger.info('Saving file from $sourcePath to $destinationPath');
      
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        throw FileException(message: 'Source file not found: $sourcePath');
      }

      // Ensure destination directory exists
      final destDir = Directory(path.dirname(destinationPath));
      if (!await destDir.exists()) {
        await destDir.create(recursive: true);
      }

      final destFile = File(destinationPath);
      await sourceFile.copy(destinationPath);
      
      return Success(destFile.path);
    } on FileException catch (e) {
      _logger.error('File error saving file', e);
      return ResultFailure(FileFailure(message: e.message, code: e.code));
    } catch (e, stackTrace) {
      _logger.error('Error saving file', e, stackTrace);
      return ResultFailure(
        StorageFailure(message: 'Failed to save file: $e'),
      );
    }
  }

  @override
  Future<Result<String>> copyFile({
    required String sourcePath,
    required String destinationPath,
  }) async {
    return await saveFile(
      sourcePath: sourcePath,
      destinationPath: destinationPath,
    );
  }

  @override
  Future<Result<String>> moveFile({
    required String sourcePath,
    required String destinationPath,
  }) async {
    try {
      _logger.info('Moving file from $sourcePath to $destinationPath');
      
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        throw FileException(message: 'Source file not found: $sourcePath');
      }

      // Ensure destination directory exists
      final destDir = Directory(path.dirname(destinationPath));
      if (!await destDir.exists()) {
        await destDir.create(recursive: true);
      }

      final destFile = await sourceFile.rename(destinationPath);
      
      return Success(destFile.path);
    } on FileException catch (e) {
      _logger.error('File error moving file', e);
      return ResultFailure(FileFailure(message: e.message, code: e.code));
    } catch (e, stackTrace) {
      _logger.error('Error moving file', e, stackTrace);
      return ResultFailure(
        StorageFailure(message: 'Failed to move file: $e'),
      );
    }
  }

  @override
  Future<Result<void>> deleteFile(String filePath) async {
    try {
      _logger.info('Deleting file: $filePath');
      
      final file = File(filePath);
      if (!await file.exists()) {
        throw FileException(message: 'File not found: $filePath');
      }

      await file.delete();
      return const Success(null);
    } on FileException catch (e) {
      _logger.error('File error deleting file', e);
      return ResultFailure(FileFailure(message: e.message, code: e.code));
    } catch (e, stackTrace) {
      _logger.error('Error deleting file', e, stackTrace);
      return ResultFailure(
        StorageFailure(message: 'Failed to delete file: $e'),
      );
    }
  }

  @override
  Future<Result<bool>> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      final exists = await file.exists();
      return Success(exists);
    } catch (e, stackTrace) {
      _logger.error('Error checking file existence', e, stackTrace);
      return ResultFailure(
        StorageFailure(message: 'Failed to check file existence: $e'),
      );
    }
  }

  @override
  Future<Result<int>> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw FileException(message: 'File not found: $filePath');
      }

      final stat = await file.stat();
      return Success(stat.size);
    } on FileException catch (e) {
      _logger.error('File error getting file size', e);
      return ResultFailure(FileFailure(message: e.message, code: e.code));
    } catch (e, stackTrace) {
      _logger.error('Error getting file size', e, stackTrace);
      return ResultFailure(
        StorageFailure(message: 'Failed to get file size: $e'),
      );
    }
  }

  @override
  Future<Result<List<String>>> listFiles(String directoryPath) async {
    try {
      _logger.info('Listing files in: $directoryPath');
      
      final directory = Directory(directoryPath);
      if (!await directory.exists()) {
        throw FileException(message: 'Directory not found: $directoryPath');
      }

      final files = <String>[];
      await for (final entity in directory.list()) {
        if (entity is File) {
          files.add(entity.path);
        }
      }
      
      return Success(files);
    } on FileException catch (e) {
      _logger.error('File error listing files', e);
      return ResultFailure(FileFailure(message: e.message, code: e.code));
    } catch (e, stackTrace) {
      _logger.error('Error listing files', e, stackTrace);
      return ResultFailure(
        StorageFailure(message: 'Failed to list files: $e'),
      );
    }
  }

  @override
  Future<Result<String>> createDirectory(String dirPath) async {
    try {
      _logger.info('Creating directory: $dirPath');
      
      final directory = Directory(dirPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      
      return Success(directory.path);
    } catch (e, stackTrace) {
      _logger.error('Error creating directory', e, stackTrace);
      return ResultFailure(
        StorageFailure(message: 'Failed to create directory: $e'),
      );
    }
  }

  @override
  Future<Result<void>> deleteDirectory(String dirPath) async {
    try {
      _logger.info('Deleting directory: $dirPath');
      
      final directory = Directory(dirPath);
      if (!await directory.exists()) {
        throw FileException(message: 'Directory not found: $dirPath');
      }

      await directory.delete(recursive: true);
      return const Success(null);
    } on FileException catch (e) {
      _logger.error('File error deleting directory', e);
      return ResultFailure(FileFailure(message: e.message, code: e.code));
    } catch (e, stackTrace) {
      _logger.error('Error deleting directory', e, stackTrace);
      return ResultFailure(
        StorageFailure(message: 'Failed to delete directory: $e'),
      );
    }
  }

  @override
  Future<Result<void>> cleanTempFiles() async {
    try {
      _logger.info('Cleaning temp files');
      
      final tempDirResult = await getTempDirectory();
      if (tempDirResult.isFailure) {
        return ResultFailure(tempDirResult.failure);
      }

      final tempDir = Directory(tempDirResult.value);
      if (await tempDir.exists()) {
        await for (final entity in tempDir.list()) {
          try {
            await entity.delete(recursive: true);
          } catch (e) {
            _logger.warning('Failed to delete temp file: ${entity.path}', e);
          }
        }
      }
      
      return const Success(null);
    } catch (e, stackTrace) {
      _logger.error('Error cleaning temp files', e, stackTrace);
      return ResultFailure(
        StorageFailure(message: 'Failed to clean temp files: $e'),
      );
    }
  }

  @override
  Future<Result<int>> getAvailableSpace() async {
    try {
      // Note: Dart doesn't provide direct API for available space
      // This is a simplified implementation
      // For production, consider using platform channels
      return const Success(0); // Placeholder
    } catch (e, stackTrace) {
      _logger.error('Error getting available space', e, stackTrace);
      return ResultFailure(
        StorageFailure(message: 'Failed to get available space: $e'),
      );
    }
  }
}
