
import 'package:material_ui/material_ui.dart';

import '../../util/const/ui/ui_constants.dart';

ThemeData _buildTheme({
  required Brightness brightness,
  required Color seedColor,
  required Color backgroundColor,
  required Color foregroundColor,
}) {
  return ThemeData(
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    ),
    scaffoldBackgroundColor: backgroundColor,
    textTheme: const TextTheme().apply(
      bodyColor: foregroundColor,
      displayColor: foregroundColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: foregroundColor,
      iconTheme: IconThemeData(
        color: foregroundColor,
      ),
    ),
    iconTheme: IconThemeData(
      color: foregroundColor,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: backgroundColor.withValues(
        alpha: brightness == Brightness.dark ? 0.88 : 0.92,
      ),
      selectedItemColor: foregroundColor,
      unselectedItemColor: foregroundColor,
      selectedIconTheme: IconThemeData(
        size: 28,
        color: foregroundColor,
      ),
      unselectedIconTheme: IconThemeData(
        size: 28,
        color: foregroundColor,
      ),
      elevation: 0,
    ),
  );
}

final ThemeData lightTheme = _buildTheme(
  brightness: Brightness.light,
  seedColor: UIConstants.lightPrimaryColor,
  backgroundColor: UIConstants.lightBackgroundColor,
  foregroundColor: UIConstants.lightTextColor,
);

final ThemeData darkTheme = _buildTheme(
  brightness: Brightness.dark,
  seedColor: UIConstants.darkPrimaryColor,
  backgroundColor: UIConstants.darkBackgroundColor,
  foregroundColor: UIConstants.darkTextColor,
);
