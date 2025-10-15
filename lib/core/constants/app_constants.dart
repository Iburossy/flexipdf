/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'FlexiPDF';
  static const String appVersion = '1.0.0';
  
  // File Constraints
  static const int maxFileSizeMB = 200;
  static const int maxFileSizeBytes = maxFileSizeMB * 1024 * 1024;
  
  // Compression Levels
  static const String compressionLow = 'low';
  static const String compressionMedium = 'medium';
  static const String compressionHigh = 'high';
  
  // Supported Formats
  static const List<String> supportedPdfFormats = ['pdf'];
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'tiff'];
  static const List<String> supportedOfficeFormats = ['docx', 'xlsx', 'pptx'];
  
  // Storage
  static const String tempFolderName = 'temp';
  static const String exportFolderName = 'exports';
  static const String vaultFolderName = 'vault';
  static const String downloadFolderName = 'FlexiPDF';
  
  // Database
  static const String dbName = 'flexipdf.db';
  static const int dbVersion = 1;
  
  // Encryption
  static const String encryptionAlgorithm = 'AES-256';
  static const int encryptionKeyLength = 256;
  
  // OCR
  static const List<String> defaultOcrLanguages = ['fra', 'eng'];
  
  // UI
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
}
