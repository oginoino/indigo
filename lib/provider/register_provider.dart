import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'theme/theme_provider.dart';
import '../../di/di.dart';
import '../util/log/debug_handler.dart';
import 'feed/feeds_list_provider.dart';

class RegisterProvider {

  RegisterProvider._();

  static List<SingleChildWidget> register() {
    DebugHandler.handleError(message: 'RegisterProvider register');
  final List<SingleChildWidget> providers = [
    ChangeNotifierProvider(
        create: (context) => ThemeProvider(persistenceService),
      ),
    ChangeNotifierProvider(
        create: (context) => FeedsListProvider(),
      ),
    ];
    return providers;
  }
}

List<SingleChildWidget> get providers => RegisterProvider.register();