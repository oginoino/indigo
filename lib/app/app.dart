import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../provider/theme/theme_provider.dart';
import '../route/router.dart';
import '../util/const/app/app_constants.dart';

class IndigoApp extends StatelessWidget {
  const IndigoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          title: AppConstants.appTitle,
          debugShowCheckedModeBanner: false,
          theme: themeProvider.currentTheme,
          routerConfig: appRouter,
        );
      },
    );
  }
}
