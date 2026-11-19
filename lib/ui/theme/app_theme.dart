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
    useMaterial3: true,
    visualDensity: VisualDensity.standard,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: foregroundColor,
      iconTheme: iconTheme,
      elevation: UIConstants.noElevation,
      scrolledUnderElevation: UIConstants.noElevation,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: UIConstants.appBarToolbarHeight,
    ),
    iconTheme: iconTheme,
    cardTheme: CardThemeData(
      color: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: UIConstants.noElevation,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.postCardRadius),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(
            alpha: isDark ? 0.28 : 0.38,
          ),
        ),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.45 : 0.6),
      space: UIConstants.spaceSm,
      thickness: 1,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: backgroundColor.withValues(
        alpha: isDark
            ? UIConstants.darkBottomNavigationBackgroundOpacity
            : UIConstants.lightBottomNavigationBackgroundOpacity,
      ),
      selectedItemColor: colorScheme.onSurface,
      unselectedItemColor: colorScheme.onSurfaceVariant,
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
