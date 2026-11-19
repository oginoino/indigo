import 'package:material_ui/material_ui.dart';

class UIConstants {
  const UIConstants._();

  static const double spaceNone = 0;
  static const double space2xs = 2;
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 12;
  static const double spaceLg = 16;
  static const double spaceXl = 24;
  static const double space2xl = 32;

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusPill = 40;

  static const double defaultPadding = spaceLg;
  static const double avatarSmallSize = 32;
  static const double avatarMediumSize = 48;
  static const double avatarLargeSize = 72;
  static const double avatarPlaceholderIconScale = 0.6;
  static const double navigationIconSize = 28;
  static const double appBarLeadingWidth = 56;
  static const double appBarToolbarHeight = 56;

  static const double navBarHeight = 40;
  static const double navBarItemSpacing = spaceSm;
  static const double navBarHorizontalPadding = spaceSm;
  static const double navBarItemBorderRadius = radiusLg;
  static const double navBarScrollInitialOffset = 0;
  static const double navBarScrollTolerance = 1;
  static const Duration navBarScrollDuration = Duration(milliseconds: 250);
  static const double navBarSelectedIndicatorThickness = 2;
  static const double noElevation = 0;

  static const double bottomNavigationHeight = 60;
  static const double bottomNavigationRadius = radiusPill;
  static const int bottomNavigationMaxVisibleItems = 5;
  static const double bottomNavigationItemWidth = 64;
  static const double bottomNavigationOuterPadding = spaceSm;
  static const double bottomNavigationBottomPadding = spaceMd;
  static const double bottomNavigationContentPadding = spaceXs;
  static const double bottomNavigationBlurSigma = 22;
  static const Duration bottomNavigationAnimationDuration = Duration(
    milliseconds: 220,
  );
  static const double bottomNavigationBorderOpacity = 0.55;

  static const double postCardSpacing = spaceSm;
  static const double postCardContentPadding = spaceMd;
  static const double postCardHorizontalInset = spaceSm;
  static const double postCardOuterSpacing = spaceXs;
  static const double postCardRadius = radiusLg;
  static const int postPreviewMaxLines = 5;
  static const double postArticleMaxWidth = 720;
  static const double postArticleHorizontalPadding = spaceLg;
  static const double postArticleBodyLineHeight = 1.75;
  static const double postArticleSectionSpacing = spaceXl;
  static const double postMediaErrorIconSize = 36;
  static const double postMediaAspectRatio = 1.2;
  static const double postMediaRadius = radiusMd;
  static const double postHeaderAvatarSize = 40;
  static const double postHeaderSpacing = spaceSm;
  static const double postHeaderTextSpacing = space2xs;
  static const double postEngagementIconSize = 20;
  static const double postEngagementItemSpacing = spaceXs;
  static const double fullscreenEngagementIconSize = 28;
  static const double fullscreenEngagementSpacing = spaceXl;
  static const double fullscreenEngagementRailWidth = 56;
  static const double fullscreenOverlayContentSpacing = spaceLg;
  static const double postMediaBorderWidth = 2;
  static const List<Shadow> postMediaTextShadows = [
    Shadow(color: Color(0xB3000000), blurRadius: 3, offset: Offset(0, 1)),
  ];
  static const double fullscreenVideoBottomInset =
      bottomNavigationHeight +
      bottomNavigationOuterPadding +
      bottomNavigationBottomPadding;
  static const int postMediaCaptionMaxLines = 4;
  static const Color fullscreenLikedColor = Color(0xFFFF5A6A);
  static const double postPhotoPairAspectRatio = 1.45;
  static const double postPhotoGridAspectRatio = 1;
  static const double postPhotoGridSpacing = spaceXs;
  static const int postPhotoGridColumns = 2;
  static const int postPhotoGridCapacity =
      postPhotoGridColumns * postPhotoGridColumns;
  static const double videoActionIconSize = 32;
  static const double videoOverlayPadding = spaceLg;
  static const Duration imageViewerTransitionDuration = Duration(
    milliseconds: 220,
  );

  static const double lightBottomNavigationBackgroundOpacity = 0.66;
  static const double darkBottomNavigationBackgroundOpacity = 0.72;
  static const double lightBottomNavigationSelectionOpacity = 0.1;
  static const double darkBottomNavigationSelectionOpacity = 0.2;

  static const Color lightPrimaryColor = Color(0xFF121212);
  static const Color darkPrimaryColor = Color(0xFFF8F8F8);
  static const Color lightBackgroundColor = Color(0xFFF8F8F8);
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color lightTextColor = Color(0xFF121212);
  static const Color darkTextColor = Color(0xFFF8F8F8);
}
