import 'package:material_ui/material_ui.dart';
import '../../di/di.dart';

ThemeData _darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: uiConstants.darkPrimaryColor),
  scaffoldBackgroundColor: uiConstants.darkBackgroundColor,
  textTheme: _textTheme,
  appBarTheme: _appBarTheme,
  iconTheme: _iconTheme,
);

TextTheme _textTheme = TextTheme(
  displayLarge: TextStyle(color: uiConstants.darkTextColor),
  displayMedium: TextStyle(color: uiConstants.darkTextColor),
  displaySmall: TextStyle(color: uiConstants.darkTextColor),
  headlineLarge: TextStyle(color: uiConstants.darkTextColor),
  headlineMedium: TextStyle(color: uiConstants.darkTextColor),
  headlineSmall: TextStyle(color: uiConstants.darkTextColor),
  titleLarge: TextStyle(color: uiConstants.darkTextColor),
  titleMedium: TextStyle(color: uiConstants.darkTextColor),
  titleSmall: TextStyle(color: uiConstants.darkTextColor),
  bodyLarge: TextStyle(color: uiConstants.darkTextColor),
  bodyMedium: TextStyle(color: uiConstants.darkTextColor),
  bodySmall: TextStyle(color: uiConstants.darkTextColor),
  labelLarge: TextStyle(color: uiConstants.darkTextColor),
  labelMedium: TextStyle(color: uiConstants.darkTextColor),
  labelSmall: TextStyle(color: uiConstants.darkTextColor),
);

AppBarTheme _appBarTheme = AppBarTheme(
  backgroundColor: Colors.transparent,
  iconTheme: IconThemeData(color: uiConstants.darkTextColor),
);

IconThemeData _iconTheme = IconThemeData(color: uiConstants.darkTextColor);

ThemeData get darkTheme => _darkTheme;