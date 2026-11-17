import '../di/di.dart';
import '../util/log/error_handler.dart';

class Bootstrap {
  const Bootstrap._();

  static Future<void> init() async {
    try {
      await DependencyInjection.init();
    } catch (error, stackTrace) {
      ErrorHandler.report(error, stackTrace, message: 'Bootstrap failed');
      rethrow;
    }
  }
}
