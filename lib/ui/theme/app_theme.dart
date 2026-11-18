import 'package:material_ui/material_ui.dart';

import '../../util/const/ui/ui_constants.dart';
import 'app_component_theme.dart';

ThemeData _buildTheme({
  required Brightness brightness,
  required Color seedColor,
  required Color backgroundColor,
  required Color foregroundColor,
}) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: brightness,
  );
  final isDark = brightness == Brightness.dark;
  final iconTheme = IconThemeData(color: foregroundColor);
  final navigationIconTheme = IconThemeData(
    size: UIConstants.navigationIconSize,
    color: foregroundColor,
  );

  return ThemeData(
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: backgroundColor,
    textTheme: const TextTheme().apply(
      bodyColor: foregroundColor,
      displayColor: foregroundColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: foregroundColor,
      iconTheme: iconTheme,
    ),
    iconTheme: iconTheme,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: backgroundColor.withValues(
        alpha: isDark
            ? UIConstants.darkBottomNavigationBackgroundOpacity
            : UIConstants.lightBottomNavigationBackgroundOpacity,
      ),
      selectedItemColor: foregroundColor,
      unselectedItemColor: foregroundColor,
      selectedIconTheme: navigationIconTheme,
      unselectedIconTheme: navigationIconTheme,
      elevation: UIConstants.noElevation,
    ),
    extensions: [
      AppComponentTheme(
        bottomNavigationSelectionColor: colorScheme.onSurface.withValues(
          alpha: isDark
              ? UIConstants.darkBottomNavigationSelectionOpacity
              : UIConstants.lightBottomNavigationSelectionOpacity,
        ),
        bottomNavigationBorderColor: colorScheme.outlineVariant.withValues(
          alpha: UIConstants.bottomNavigationBorderOpacity,
        ),
      ),
    ],
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
