import 'package:material_ui/material_ui.dart';

import '../../util/const/ui/ui_constants.dart';

@immutable
class MediaOverlayTheme extends ThemeExtension<MediaOverlayTheme> {
  const MediaOverlayTheme({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.secondaryForegroundColor,
    required this.controlBackgroundColor,
    required this.gradientTopColor,
    required this.gradientBottomColor,
    required this.likedColor,
  });

  static const standard = MediaOverlayTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
    secondaryForegroundColor: Colors.white70,
    controlBackgroundColor: Colors.black54,
    gradientTopColor: Colors.black38,
    gradientBottomColor: Colors.black87,
    likedColor: UIConstants.likedColor,
  );

  static MediaOverlayTheme of(BuildContext context) =>
      Theme.of(context).extension<MediaOverlayTheme>() ?? standard;

  final Color backgroundColor;
  final Color foregroundColor;
  final Color secondaryForegroundColor;
  final Color controlBackgroundColor;
  final Color gradientTopColor;
  final Color gradientBottomColor;
  final Color likedColor;

  @override
  MediaOverlayTheme copyWith({
    Color? backgroundColor,
    Color? foregroundColor,
    Color? secondaryForegroundColor,
    Color? controlBackgroundColor,
    Color? gradientTopColor,
    Color? gradientBottomColor,
    Color? likedColor,
  }) {
    return MediaOverlayTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      secondaryForegroundColor:
          secondaryForegroundColor ?? this.secondaryForegroundColor,
      controlBackgroundColor:
          controlBackgroundColor ?? this.controlBackgroundColor,
      gradientTopColor: gradientTopColor ?? this.gradientTopColor,
      gradientBottomColor: gradientBottomColor ?? this.gradientBottomColor,
      likedColor: likedColor ?? this.likedColor,
    );
  }

  @override
  MediaOverlayTheme lerp(covariant MediaOverlayTheme? other, double t) {
    if (other == null) return this;

    return MediaOverlayTheme(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      foregroundColor: Color.lerp(foregroundColor, other.foregroundColor, t)!,
      secondaryForegroundColor: Color.lerp(
        secondaryForegroundColor,
        other.secondaryForegroundColor,
        t,
      )!,
      controlBackgroundColor: Color.lerp(
        controlBackgroundColor,
        other.controlBackgroundColor,
        t,
      )!,
      gradientTopColor: Color.lerp(
        gradientTopColor,
        other.gradientTopColor,
        t,
      )!,
      gradientBottomColor: Color.lerp(
        gradientBottomColor,
        other.gradientBottomColor,
        t,
      )!,
      likedColor: Color.lerp(likedColor, other.likedColor, t)!,
    );
  }
}
