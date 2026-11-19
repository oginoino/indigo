import 'package:flutter_test/flutter_test.dart';
import 'package:indigo/ui/theme/app_theme.dart';

void main() {
  test('app bar background matches the scaffold in both themes', () {
    for (final theme in [lightTheme, darkTheme]) {
      expect(theme.appBarTheme.backgroundColor, theme.scaffoldBackgroundColor);
    }
  });
}
