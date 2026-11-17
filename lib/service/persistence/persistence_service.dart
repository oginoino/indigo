import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersistenceService {
  final SharedPreferences _preferences;

  PersistenceService(this._preferences);

  Future<void> setThemeMode(ThemeMode themeMode) async {
    await _preferences.setString('themeMode', themeMode.name);
  }

  ThemeMode getThemeMode() {
    return _preferences.getString('themeMode') == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setIsDarkMode(bool isDarkMode) async {
    await _preferences.setBool('isDarkMode', isDarkMode);
  }

  bool getIsDarkMode() {
    return _preferences.getBool('isDarkMode') ?? false;
  }
}