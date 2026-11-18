import '../di/di.dart';

class Bootstrap {
  const Bootstrap._();

  static Future<void> init() => DependencyInjection.init();
}
