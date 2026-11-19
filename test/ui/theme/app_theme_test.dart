import 'package:flutter_test/flutter_test.dart';
import 'package:indigo/ui/theme/app_theme.dart';
import 'package:indigo/ui/theme/media_overlay_theme.dart';

void main() {
  test('app bar background matches the scaffold in both themes', () {
    for (final theme in [lightTheme, darkTheme]) {
      expect(theme.appBarTheme.backgroundColor, theme.scaffoldBackgroundColor);
    }
  });

  test('media overlay colors are available in both themes', () {
    for (final theme in [lightTheme, darkTheme]) {
      final mediaTheme = theme.extension<MediaOverlayTheme>();
      expect(mediaTheme, isNotNull);
      expect(
        mediaTheme!.foregroundColor,
        MediaOverlayTheme.standard.foregroundColor,
      );
      expect(
        mediaTheme.backgroundColor,
        MediaOverlayTheme.standard.backgroundColor,
      );
    }
  });
}
