import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Central logger. Only emits in debug mode, and should only be used for
/// API traffic and error conditions.
class AppLogger {
  AppLogger._();

  static void api(String message, {String name = 'API'}) {
    if (!kDebugMode) return;
    developer.log(message, name: name);
  }

  static void error(Object error, [StackTrace? stackTrace, String? context]) {
    if (!kDebugMode) return;
    developer.log(
      context ?? error.toString(),
      name: 'ERROR',
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
