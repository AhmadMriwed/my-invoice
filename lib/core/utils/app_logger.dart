import 'package:flutter/foundation.dart';

class AppLogger {
  const AppLogger._();

  static void log(Object? message) {
    if (kDebugMode) {
      debugPrint(message?.toString());
    }
  }

  static void error(Object error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('ERROR: $error');
      if (stackTrace != null) {
        debugPrint(stackTrace.toString());
      }
    }
  }
}
