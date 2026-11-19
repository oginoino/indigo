import 'package:material_ui/material_ui.dart';

class UIConstants {
  const UIConstants._();

  static const double defaultPadding = 16;
  static const double avatarSmallSize = 32;
  static const double avatarMediumSize = 48;
  static const double avatarLargeSize = 72;
  static const double avatarPlaceholderIconScale = 0.6;
  static const double navigationIconSize = 28;
  static const double appBarLeadingWidth = 56;
  static const double appBarToolbarHeight = 56;

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

  static const double postCardSpacing = 12;
  static const double postCardRadius = 16;
  static const double postMediaAspectRatio = 1.2;
  static const double postMediaRadius = 12;
  static const double postHeaderAvatarSize = 44;
  static const double postHeaderSpacing = 12;
  static const double postHeaderTextSpacing = 2;
  static const double postEngagementIconSize = 20;
  static const double postEngagementItemSpacing = 6;
  static const double fullscreenEngagementIconSize = 28;
  static const double fullscreenEngagementSpacing = 24;
  static const double fullscreenEngagementRailWidth = 56;
  static const double fullscreenOverlayContentSpacing = 16;
  static const double postMediaBorderWidth = 2;
  static const List<Shadow> postMediaTextShadows = [
    Shadow(color: Colors.black, blurRadius: 8),
  ];
  static const double fullscreenVideoBottomInset =
      bottomNavigationHeight +
      bottomNavigationOuterPadding +
      bottomNavigationBottomPadding;
  static const int postMediaCaptionMaxLines = 4;
  static const Color fullscreenLikedColor = Color(0xFFFF5A6A);
  static const double postPhotoPairAspectRatio = 1.45;
  static const double postPhotoGridAspectRatio = 1;
  static const double postPhotoGridSpacing = 4;
  static const int postPhotoGridColumns = 2;
  static const int postPhotoGridCapacity =
      postPhotoGridColumns * postPhotoGridColumns;
  static const double videoActionIconSize = 32;
  static const double videoOverlayPadding = 20;
  static const Duration imageViewerTransitionDuration = Duration(
    milliseconds: 220,
  );

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
