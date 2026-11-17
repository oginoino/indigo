import 'package:material_ui/material_ui.dart';
import '../../di/di.dart';

ThemeData _lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: uiConstants.lightPrimaryColor),
  scaffoldBackgroundColor: uiConstants.lightBackgroundColor,
  textTheme: _textTheme,
  appBarTheme: _appBarTheme,
  iconTheme: _iconTheme,
);

TextTheme _textTheme = TextTheme(
  displayLarge: TextStyle(color: uiConstants.lightTextColor),
  displayMedium: TextStyle(color: uiConstants.lightTextColor),
  displaySmall: TextStyle(color: uiConstants.lightTextColor),
  headlineLarge: TextStyle(color: uiConstants.lightTextColor),
  headlineMedium: TextStyle(color: uiConstants.lightTextColor),
  headlineSmall: TextStyle(color: uiConstants.lightTextColor),
  titleLarge: TextStyle(color: uiConstants.lightTextColor),
  titleMedium: TextStyle(color: uiConstants.lightTextColor),
  titleSmall: TextStyle(color: uiConstants.lightTextColor),
  bodyLarge: TextStyle(color: uiConstants.lightTextColor),
  bodyMedium: TextStyle(color: uiConstants.lightTextColor),
  bodySmall: TextStyle(color: uiConstants.lightTextColor),
  labelLarge: TextStyle(color: uiConstants.lightTextColor),
  labelMedium: TextStyle(color: uiConstants.lightTextColor),
  labelSmall: TextStyle(color: uiConstants.lightTextColor),
);

AppBarTheme _appBarTheme = AppBarTheme(
  backgroundColor: Colors.transparent,
  iconTheme: IconThemeData(color: uiConstants.lightTextColor),
);

IconThemeData _iconTheme = IconThemeData(color: uiConstants.lightTextColor);

ThemeData get lightTheme => _lightTheme;