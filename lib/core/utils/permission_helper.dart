import 'package:permission_handler/permission_handler.dart';
import 'logger.dart';

/// Helper class for managing app permissions
class PermissionHelper {
  static final Logger _logger = Logger('PermissionHelper');

  /// Request storage permission
  static Future<bool> requestStoragePermission() async {
    try {
      _logger.info('Requesting storage permission');
      
      // For Android 13+ (API 33+), use media permissions
      // For older versions, use storage permission
      final permissions = [
        Permission.photos,
        Permission.videos,
        Permission.audio,
      ];
      
      // Check if all permissions are granted
      bool allGranted = true;
      for (final permission in permissions) {
        if (!await permission.isGranted) {
          allGranted = false;
          break;
        }
      }
      
      if (allGranted) {
        _logger.info('All storage permissions already granted');
        return true;
      }

      // Request all permissions
      final statuses = await permissions.request();
      
      // Check if at least one is granted
      bool anyGranted = false;
      for (final status in statuses.values) {
        if (status.isGranted || status.isLimited) {
          anyGranted = true;
          break;
        }
      }
      
      if (anyGranted) {
        _logger.info('Storage permissions granted');
        return true;
      }
      
      // Check if permanently denied
      bool permanentlyDenied = false;
      for (final status in statuses.values) {
        if (status.isPermanentlyDenied) {
          permanentlyDenied = true;
          break;
        }
      }
      
      if (permanentlyDenied) {
        _logger.warning('Storage permissions permanently denied');
        await openSettings();
        return false;
      }
      
      _logger.warning('Storage permissions denied');
      return false;
    } catch (e, stackTrace) {
      _logger.error('Error requesting storage permission', e, stackTrace);
      return false;
    }
  }

  /// Request camera permission
  static Future<bool> requestCameraPermission() async {
    try {
      _logger.info('Requesting camera permission');
      
      // Check if already granted
      if (await Permission.camera.isGranted) {
        _logger.info('Camera permission already granted');
        return true;
      }

      // Request permission
      final status = await Permission.camera.request();
      
      if (status.isGranted) {
        _logger.info('Camera permission granted');
        return true;
      } else if (status.isPermanentlyDenied) {
        _logger.warning('Camera permission permanently denied');
        await openSettings();
        return false;
      } else {
        _logger.warning('Camera permission denied');
        return false;
      }
    } catch (e, stackTrace) {
      _logger.error('Error requesting camera permission', e, stackTrace);
      return false;
    }
  }

  /// Request photos permission (iOS)
  static Future<bool> requestPhotosPermission() async {
    try {
      _logger.info('Requesting photos permission');
      
      // Check if already granted
      if (await Permission.photos.isGranted) {
        _logger.info('Photos permission already granted');
        return true;
      }

      // Request permission
      final status = await Permission.photos.request();
      
      if (status.isGranted || status.isLimited) {
        _logger.info('Photos permission granted');
        return true;
      } else if (status.isPermanentlyDenied) {
        _logger.warning('Photos permission permanently denied');
        await openSettings();
        return false;
      } else {
        _logger.warning('Photos permission denied');
        return false;
      }
    } catch (e, stackTrace) {
      _logger.error('Error requesting photos permission', e, stackTrace);
      return false;
    }
  }

  /// Request manage external storage permission (Android 11+)
  static Future<bool> requestManageExternalStoragePermission() async {
    try {
      _logger.info('Requesting manage external storage permission');
      
      // Check if already granted
      if (await Permission.manageExternalStorage.isGranted) {
        _logger.info('Manage external storage permission already granted');
        return true;
      }

      // Request permission
      final status = await Permission.manageExternalStorage.request();
      
      if (status.isGranted) {
        _logger.info('Manage external storage permission granted');
        return true;
      } else if (status.isPermanentlyDenied) {
        _logger.warning('Manage external storage permission permanently denied');
        await openSettings();
        return false;
      } else {
        _logger.warning('Manage external storage permission denied');
        return false;
      }
    } catch (e, stackTrace) {
      _logger.error('Error requesting manage external storage permission', e, stackTrace);
      return false;
    }
  }

  /// Request all necessary permissions for PDF operations
  static Future<bool> requestPdfPermissions() async {
    _logger.info('Requesting all PDF permissions');
    
    final storageGranted = await requestStoragePermission();
    
    if (!storageGranted) {
      _logger.warning('Storage permission not granted');
      return false;
    }
    
    return true;
  }

  /// Request all necessary permissions for scanning
  static Future<bool> requestScanPermissions() async {
    _logger.info('Requesting all scan permissions');
    
    final cameraGranted = await requestCameraPermission();
    final storageGranted = await requestStoragePermission();
    
    if (!cameraGranted || !storageGranted) {
      _logger.warning('Not all scan permissions granted');
      return false;
    }
    
    return true;
  }

  /// Check if storage permission is granted
  static Future<bool> hasStoragePermission() async {
    return await Permission.storage.isGranted;
  }

  /// Check if camera permission is granted
  static Future<bool> hasCameraPermission() async {
    return await Permission.camera.isGranted;
  }

  /// Check if photos permission is granted
  static Future<bool> hasPhotosPermission() async {
    return await Permission.photos.isGranted;
  }

  /// Open app settings
  static Future<void> openSettings() async {
    _logger.info('Opening app settings');
    await openAppSettings();
  }

  /// Get permission status message
  static String getPermissionStatusMessage(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Permission granted';
      case PermissionStatus.denied:
        return 'Permission denied. Please grant permission to continue.';
      case PermissionStatus.permanentlyDenied:
        return 'Permission permanently denied. Please enable it in app settings.';
      case PermissionStatus.restricted:
        return 'Permission restricted by system.';
      case PermissionStatus.limited:
        return 'Limited permission granted.';
      case PermissionStatus.provisional:
        return 'Provisional permission granted.';
    }
  }
}
