import 'package:material_ui/material_ui.dart';

ThemeData _darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
  scaffoldBackgroundColor: Color(0xFF121212),
);

ThemeData get darkTheme => _darkTheme;