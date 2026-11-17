import 'package:material_ui/material_ui.dart';

ThemeData _lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
  scaffoldBackgroundColor: Color(0xFFF8F8F8),
);

ThemeData get lightTheme => _lightTheme;