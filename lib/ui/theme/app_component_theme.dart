import 'package:material_ui/material_ui.dart';

@immutable
class AppComponentTheme extends ThemeExtension<AppComponentTheme> {
  const AppComponentTheme({
    required this.bottomNavigationSelectionColor,
    required this.bottomNavigationBorderColor,
  });

  final Color bottomNavigationSelectionColor;
  final Color bottomNavigationBorderColor;

  @override
  AppComponentTheme copyWith({
    Color? bottomNavigationSelectionColor,
    Color? bottomNavigationBorderColor,
  }) {
    return AppComponentTheme(
      bottomNavigationSelectionColor:
          bottomNavigationSelectionColor ?? this.bottomNavigationSelectionColor,
      bottomNavigationBorderColor:
          bottomNavigationBorderColor ?? this.bottomNavigationBorderColor,
    );
  }

  @override
  AppComponentTheme lerp(covariant AppComponentTheme? other, double t) {
    if (other == null) return this;

    return AppComponentTheme(
      bottomNavigationSelectionColor: Color.lerp(
        bottomNavigationSelectionColor,
        other.bottomNavigationSelectionColor,
        t,
      )!,
      bottomNavigationBorderColor: Color.lerp(
        bottomNavigationBorderColor,
        other.bottomNavigationBorderColor,
        t,
      )!,
    );
  }
}
