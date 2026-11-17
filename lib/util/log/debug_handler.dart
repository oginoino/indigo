import 'package:flutter/foundation.dart';
class DebugHandler {
  DebugHandler._();

  static void handleError({String? message}) {
    if (kDebugMode) {
      print('$message: $message');
    }
  }
}