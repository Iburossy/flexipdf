import 'dart:developer' as developer;

/// Simple logger utility
/// In production, consider using logger package
class Logger {
  final String _tag;

  Logger(this._tag);

  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    _log('DEBUG', message, error, stackTrace);
  }

  void info(String message, [Object? error, StackTrace? stackTrace]) {
    _log('INFO', message, error, stackTrace);
  }

  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _log('WARNING', message, error, stackTrace);
  }

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log('ERROR', message, error, stackTrace);
  }

  void _log(String level, String message, Object? error, StackTrace? stackTrace) {
    final logMessage = '[$_tag] $level: $message';
    developer.log(
      logMessage,
      name: _tag,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
