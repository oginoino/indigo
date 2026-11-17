import 'package:shared_preferences/shared_preferences.dart';

class PersistenceService {
  PersistenceService(this._preferences);

  static const _isDarkModeKey = 'isDarkMode';

  final SharedPreferences _preferences;

  Future<void> setIsDarkMode(bool isDarkMode) {
    return _preferences.setBool(_isDarkModeKey, isDarkMode);
  }

  bool getIsDarkMode() {
    return _preferences.getBool(_isDarkModeKey) ?? false;
  }
}
