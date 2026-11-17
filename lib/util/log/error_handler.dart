import 'package:flutter/foundation.dart';

class ErrorHandler {
  ErrorHandler._();

  static void handleError(Object error, {String? message}) {
    if (kDebugMode) {
      print('$message: $error');
    }
    throw Exception(error);
  }
}