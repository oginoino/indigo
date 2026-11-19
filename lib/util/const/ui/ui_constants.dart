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
  static const double avatarXSmallSize = 24;
  static const double avatarSmallSize = 32;
  static const double avatarMediumSize = 48;
  static const double avatarLargeSize = 72;
  static const double avatarPlaceholderIconScale = 0.6;
  static const int avatarGroupMaxVisible = 3;
  static const double avatarGroupOverlapRatio = 0.3;
  static const double avatarGroupRingWidth = 2;
  static const double friendsNavCtaIconSize = 20;
  static const double navigationIconSize = 28;
  static const double appBarLeadingWidth = 56;
  static const double appBarToolbarHeight = 56;

  static const double navBarHeight = 48;
  static const double navBarItemSpacing = spaceSm;
  static const double navBarHorizontalPadding = spaceSm;
  static const double navBarItemBorderRadius = radiusLg;
  static const double navBarScrollInitialOffset = 0;
  static const double navBarScrollTolerance = 1;
  static const Duration navBarScrollDuration = Duration(milliseconds: 250);
  static const double navBarSelectedIndicatorThickness = 2;
  static const double noElevation = 0;

  static const double bottomNavigationHeight = 60;
  static const double bottomNavigationCompactHeight = 48;
  static const double bottomNavigationRadius = radiusPill;
  static const double bottomNavigationCompactIconSize = 24;
  static const double bottomNavigationCompactHorizontalInset = spaceMd;
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
  static const double postCardOuterSpacing = spaceNone;
  static const double postCardRadius = radiusLg;
  static const double postFeedDividerHeight = spaceLg;
  static const double postFeedDividerThickness = 0.5;
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
  static const double postLocationIconSize = 14;
  static const double postLocationIconSpacing = space2xs;
  static const double minimumInteractiveTargetSize = 48;
  static const double postEngagementButtonSize = minimumInteractiveTargetSize;
  static const double postEngagementIconSize = 20;
  static const double postEngagementItemSpacing = spaceXs;
  static const double fullscreenEngagementIconSize = 28;
  static const double fullscreenEngagementSpacing = spaceSm;
  static const double fullscreenEngagementRailWidth = 56;
  static const double fullscreenOverlayContentSpacing = spaceLg;
  static const double fullscreenEngagementRightInset = spaceSm;
  static const double fullscreenLandscapeActionRailWidthFactor = 0.42;
  static const double fullscreenLandscapeActionRailMaxWidth = 320;
  static const double postMediaBorderWidth = 2;
  static const double postMediaErrorCompactBreakpoint = 180;
  static const List<Shadow> postMediaTextShadows = [
    Shadow(color: Color(0xB3000000), blurRadius: 3, offset: Offset(0, 1)),
  ];
  static const double fullscreenVideoBottomGap = spaceMd;
  static const double postPhotoPairAspectRatio = 1.45;
  static const double postPhotoGridAspectRatio = 1;
  static const double postPhotoGridSpacing = spaceXs;
  static const int postPhotoGridColumns = 2;
  static const int postPhotoGridCapacity =
      postPhotoGridColumns * postPhotoGridColumns;
  static const double videoActionIconSize = 32;
  static const double videoOverlayPadding = spaceLg;
  static const double videoOverlayGradientMiddleStop = 0.4;
  static const double audioPlayerHeight = 48;
  static const double audioPlayerHorizontalPadding = spaceSm;
  static const double audioPlayerButtonSize = 40;
  static const double audioPlayerIconSize = 22;
  static const double audioPlayerSpacing = spaceSm;
  static const double audioPlayerWaveformBarWidth = 2;
  static const double audioPlayerWaveformBarSpacing = 2;
  static const double audioPlayerWaveformHeight = 20;
  static const Duration audioPlayerSeekStep = Duration(seconds: 5);
  static const Duration imageViewerTransitionDuration = Duration(
    milliseconds: 220,
  );

  static const double storyAvatarSize = 64;
  static const double storyRingWidth = 3;
  static const double storyRingGap = 2;
  static const double storyItemWidth = 76;
  static const double storyItemSpacing = spaceMd;
  static const double storyLabelSpacing = spaceXs;
  static const double storyRowVerticalPadding = spaceMd;
  static const double storyRowHeight = 108;
  static const double storyAddBadgeSize = 20;
  static const double storyAddIconSize = 14;
  static const int storyLabelMaxLines = 1;

  static const Duration storyViewerDisplayDuration = Duration(seconds: 5);
  static const Duration storyViewerTransitionDuration = Duration(
    milliseconds: 220,
  );
  static const double storyViewerProgressHeight = 3;
  static const double storyViewerProgressRadius = 2;
  static const double storyViewerProgressSpacing = spaceXs;
  static const double storyViewerProgressTrackOpacity = 0.35;
  static const double storyViewerTopPadding = spaceMd;
  static const double storyViewerHorizontalPadding = spaceMd;
  static const double storyViewerHeaderSpacing = spaceSm;
  static const double storyViewerAvatarSize = avatarSmallSize;
  static const double storyViewerCloseIconSize = 24;
  static const double storyViewerFallbackIconSize = 48;
  static const double storyViewerCaptionBottomPadding = space2xl;
  static const double storyViewerCaptionSpacing = spaceXl;

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
  static const Color lightHashtagLinkColor = Color(0xFF1565C0);
  static const Color darkHashtagLinkColor = Color(0xFF90CAF9);
}
