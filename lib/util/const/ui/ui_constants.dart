import 'package:material_ui/material_ui.dart';

class UIConstants {
  const UIConstants._();

  static const double defaultPadding = 16;
  static const double avatarSize = 16;
  static const double navigationIconSize = 28;

  static const double navBarHeight = 40;
  static const double navBarItemSpacing = 8;
  static const double navBarHorizontalPadding = 8;
  static const double navBarItemBorderRadius = 16;
  static const double navBarScrollInitialOffset = 0;
  static const double navBarScrollTolerance = 1;
  static const Duration navBarScrollDuration = Duration(milliseconds: 250);
  static const double navBarSelectedIndicatorThickness = 2;
  static const double noElevation = 0;

  static const double bottomNavigationHeight = 60;
  static const double bottomNavigationRadius = 40;
  static const int bottomNavigationMaxVisibleItems = 5;
  static const double bottomNavigationItemWidth = 64;
  static const double bottomNavigationOuterPadding = defaultPadding;
  static const double bottomNavigationBottomPadding = 12;
  static const double bottomNavigationContentPadding = 5;
  static const double bottomNavigationBlurSigma = 18;
  static const Duration bottomNavigationAnimationDuration = Duration(
    milliseconds: 220,
  );
  static const double bottomNavigationBorderOpacity = 0.55;

  static const double lightBottomNavigationBackgroundOpacity = 0.92;
  static const double darkBottomNavigationBackgroundOpacity = 0.88;
  static const double lightBottomNavigationSelectionOpacity = 0.07;
  static const double darkBottomNavigationSelectionOpacity = 0.16;

  static const Color lightPrimaryColor = Color(0xFF121212);
  static const Color darkPrimaryColor = Color(0xFFF8F8F8);
  static const Color lightBackgroundColor = Color(0xFFF8F8F8);
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color lightTextColor = Color(0xFF121212);
  static const Color darkTextColor = Color(0xFFF8F8F8);
}
