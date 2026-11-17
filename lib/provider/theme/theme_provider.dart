import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../service/persistence/persistence_service.dart';
import '../../ui/theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider(this._persistenceService) {
    _isDarkMode = _persistenceService.getIsDarkMode();
    _currentTheme = _isDarkMode ? darkTheme : lightTheme;
  }

  final PersistenceService _persistenceService;

  late bool _isDarkMode;
  late ThemeData _currentTheme;

  ThemeData get currentTheme => _currentTheme;
  bool get isDarkMode => _isDarkMode;

  void setDarkMode(bool value) {
    if (_isDarkMode == value) return;

    _isDarkMode = value;
    _currentTheme = value ? darkTheme : lightTheme;
    unawaited(_persistenceService.setIsDarkMode(value));
    notifyListeners();
  }

  void toggleTheme() => setDarkMode(!_isDarkMode);
}
