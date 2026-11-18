import 'package:flutter/foundation.dart';

import '../const/app/app_strings.dart';

class ErrorHandler {
  const ErrorHandler._();

  static void report(Object error, StackTrace stackTrace, {String? message}) {
    if (!kDebugMode) return;

    final prefix = message ?? AppStrings.genericError;
    debugPrint('$prefix: $error');
    debugPrint('$stackTrace');
  }
}
