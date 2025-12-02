import 'package:flutter/foundation.dart';

class DebugConfig {
  static void initializeDebug() {
    if (kDebugMode) {
      // Disable debug logging in release mode
      debugPrint('Debug mode initialized');
    }
  }

  static void logError(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      debugPrint('ERROR: $message');
      if (error != null) {
        debugPrint('Error details: $error');
      }
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  static void logInfo(String message) {
    if (kDebugMode) {
      debugPrint('INFO: $message');
    }
  }
}
