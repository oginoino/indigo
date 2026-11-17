import 'app/app.dart';
import 'util/log/error_handler.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'app/bootstrap.dart';
import 'provider/register_provider.dart';
Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Bootstrap.init();
    runApp(
      MultiProvider(providers: providers, child: const IndigoApp()),
    );

  } catch (e) {
    ErrorHandler.handleError(e, message: 'App error');
  }
}
