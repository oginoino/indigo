import 'package:indigo/util/const/app/app_constants.dart';
import 'package:material_ui/material_ui.dart';
import '../ui/page/home_page.dart';
import 'package:provider/provider.dart';
import '../provider/theme/theme_provider.dart';

class IndigoApp extends StatelessWidget {
  const IndigoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: AppConstants.appTitle,
          debugShowCheckedModeBanner: false,
          theme: themeProvider.currentTheme,
          home: const HomePage(),
        );
      },
    );
  }
}   

