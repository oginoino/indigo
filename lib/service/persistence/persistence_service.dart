import 'package:shared_preferences/shared_preferences.dart';

class PersistenceService {
  PersistenceService(this._preferences);

  static const _isDarkModeKey = 'isDarkMode';
  static const _pinnedHashtagIdsKey = 'pinnedHashtagIds';
  static const _navFeedOrderKey = 'navFeedOrder';

  final SharedPreferences _preferences;

  Future<void> setIsDarkMode(bool isDarkMode) {
    return _preferences.setBool(_isDarkModeKey, isDarkMode);
  }

  bool getIsDarkMode() {
    return _preferences.getBool(_isDarkModeKey) ?? false;
  }

  List<String> getPinnedHashtagIds() =>
      _preferences.getStringList(_pinnedHashtagIdsKey) ?? const [];

  Future<void> setPinnedHashtagIds(List<String> ids) async {
    final saved = await _preferences.setStringList(_pinnedHashtagIdsKey, ids);
    if (!saved) {
      throw StateError('Could not save pinned hashtags.');
    }
  }

  List<String> getNavFeedOrder() =>
      _preferences.getStringList(_navFeedOrderKey) ?? const [];

  Future<void> setNavFeedOrder(List<String> routes) async {
    final saved = await _preferences.setStringList(_navFeedOrderKey, routes);
    if (!saved) {
      throw StateError('Could not save navigation feed order.');
    }
  }
}
