import 'package:indigo/di/di.dart';
import 'package:indigo/util/log/error_handler.dart';
import 'package:indigo/util/log/debug_handler.dart';


class Bootstrap {
  Bootstrap._();
static Future<void> init() async { 
  DebugHandler.handleError(message: 'Bootstrap init');
      try {
        await DependencyInjection.init();
      } catch (e) {
        ErrorHandler.handleError(e, message: 'Bootstrap error');
      } finally {
        DebugHandler.handleError(message: 'Bootstrap finally');
      }
  }

}
