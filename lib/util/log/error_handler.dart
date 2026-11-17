import 'package:flutter/foundation.dart';

class ErrorHandler {
  const ErrorHandler._();

  static void report(Object error, StackTrace stackTrace, {String? message}) {
    if (!kDebugMode) return;

    final prefix = message ?? 'Error';
    debugPrint('$prefix: $error');
    debugPrint('$stackTrace');
  }
}
