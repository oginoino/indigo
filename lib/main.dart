import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'app/bootstrap.dart';
import 'provider/app_providers.dart';
import 'util/const/app/app_strings.dart';
import 'util/log/error_handler.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Bootstrap.init();
    runApp(MultiProvider(providers: appProviders, child: const IndigoApp()));
  } catch (error, stackTrace) {
    ErrorHandler.report(error, stackTrace, message: AppStrings.startupFailed);
    rethrow;
  }
}
