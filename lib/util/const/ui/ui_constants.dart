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

  // ---------------------------------------------------------------------------
  // Engagement animation tokens
  // ---------------------------------------------------------------------------
  static const Duration engagementFxDuration = Duration(milliseconds: 650);
  static const Duration engagementPressDuration = Duration(milliseconds: 110);
  static const Duration engagementColorDuration = Duration(milliseconds: 250);
  static const Duration engagementIconSwitchDuration = Duration(
    milliseconds: 180,
  );
  static const double engagementPressScale = 0.82;
  static const double engagementBurstSizeFactor = 1.6;

  // ---------------------------------------------------------------------------
  // Nav item animation tokens
  // ---------------------------------------------------------------------------
  static const double navItemPressScale = 0.95;

  // ---------------------------------------------------------------------------
  // Audio player waveform tokens
  // ---------------------------------------------------------------------------
  static const double audioPlayerWaveformIntroScale = 1.6;
  static const double audioPlayerWaveformIntroSweep = 0.6;

  // ---------------------------------------------------------------------------
  // Bottom navigation bar opacities
  // ---------------------------------------------------------------------------
  static const double lightBottomNavigationBackgroundOpacity = 0.66;
  static const double darkBottomNavigationBackgroundOpacity = 0.72;
  static const double lightBottomNavigationSelectionOpacity = 0.1;
  static const double darkBottomNavigationSelectionOpacity = 0.2;

  // ---------------------------------------------------------------------------
  // Colors & tokens
  // ---------------------------------------------------------------------------
  /// Cor de destaque para reações (curtidas) — usada em overlays e cards.
  static const Color likedColor = Color(0xFFFF5A6A);

  static const Color lightPrimaryColor = Color(0xFF121212);
  static const Color darkPrimaryColor = Color(0xFFF8F8F8);
  static const Color lightBackgroundColor = Color(0xFFF8F8F8);
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color lightTextColor = Color(0xFF121212);
  static const Color darkTextColor = Color(0xFFF8F8F8);
  static const Color lightHashtagLinkColor = Color(0xFF1565C0);
  static const Color darkHashtagLinkColor = Color(0xFF90CAF9);

  // ---------------------------------------------------------------------------
  // Comment section tokens
  // ---------------------------------------------------------------------------
  static const double commentAvatarSize = avatarSmallSize;
  static const double commentInputAvatarSize = avatarXSmallSize;
  /// Recuo horizontal aplicado a respostas (replies).
  static const double commentIndent = spaceLg;
  static const double commentSpacing = spaceMd;
  static const double commentItemSpacing = spaceSm;
  static const double commentContentSpacing = space2xs;
  static const double commentInputHeight = 48;
  static const double commentInputBorderRadius = radiusPill;
  static const double commentInputHorizontalPadding = spaceSm;
  static const double commentLikeIconSize = 16;
  static const double commentLikeButtonSize = 32;
  static const int commentMaxLines = 5;
  static const int commentRepliesInitialCount = 3;

  // ---------------------------------------------------------------------------
  // Comments bottom sheet tokens
  // ---------------------------------------------------------------------------
  static const double commentSheetInitialChildSize = 0.6;
  static const double commentSheetMinChildSize = 0.4;
  static const double commentSheetMaxChildSize = 0.92;
  static const double commentSheetHeaderHeight = 56;
  static const double commentSheetInputPadding = spaceMd;
  static const double commentSheetDragHandleWidth = 36;
  static const double commentSheetDragHandleHeight = 4;
  static const double commentSheetDragHandleRadius = 2;
  static const double commentSheetHorizontalPadding = spaceLg;

  // ---------------------------------------------------------------------------
  // Create page tokens
  // ---------------------------------------------------------------------------
  static const double createTypeGridColumns = 3;
  static const double createTypeGridChildAspectRatio = 0.9;
  static const double createTypeGridSpacing = spaceSm;
  static const double createTypeGridPadding = spaceLg;
  static const double createTypeCardRadius = radiusLg;
  static const double createTypeIconSize = 28;
  static const double createTypeCardIconPadding = spaceLg;
  static const double createTypeCardLabelSpacing = spaceXs;

  static const double createEditorVerticalPadding = spaceLg;
  static const double createEditorHorizontalPadding = spaceLg;
  static const double createEditorSectionSpacing = spaceMd;
  static const double createEditorFieldRadius = radiusMd;
  static const double createEditorMediaPreviewSize = 72;
  static const double createEditorMediaAddRadius = radiusMd;
  static const double createEditorPollOptionRadius = radiusMd;
  static const double createEditorPollSpacing = spaceXs;
  static const double createEditorToolbarHeight = 48;
  static const double createEditorAvatarSize = avatarSmallSize;
  static const double createEditorAvatarSpacing = spaceSm;
  static const Duration createPublishFeedback = Duration(milliseconds: 1800);
  static const int postBodySoftLimit = 240;
  static const int postBodyHardLimit = 500;
  static const double mediaThumbBadgeOffset = 2.0;

  // Media picker / camera tokens
  static const double mediaPickerHeaderHeight = 56;
  static const double mediaPickerCameraPreviewRatio = 0.75;
  static const double mediaPickerGridSpacing = space2xs;
  static const double mediaPickerGridColumns = 3;
  static const double mediaPickerThumbRadius = radiusSm;
  static const double mediaPickerSelectionBadgeSize = 22;
  static const double mediaPickerSelectionBorderWidth = 2.5;
  static const double mediaPickerCameraButtonSize = 72;
  static const double mediaPickerCameraButtonInner = 60;
  static const double mediaPickerTabBarHeight = 44;
  static const double mediaPickerFabSize = 56;
  static const Duration mediaPickerSheetSnap = Duration(milliseconds: 320);
  static const double mediaPickerSheetMinFraction = 0.45;
  static const double mediaPickerSheetMaxFraction = 0.95;
  static const double mediaPickerSheetInitialFraction = 0.55;
  static const double mediaPickerDragHandleWidth = 36;
  static const double mediaPickerDragHandleHeight = 4;
  static const double mediaPickerDragHandleRadius = 2;

  // Audio recorder
  static const double createAudioRecorderSize = 96;
  static const double createAudioWaveBarWidth = 3;
  static const double createAudioWaveBarMaxHeight = 48;
  static const double createAudioWaveBarSpacing = 3;
  static const Duration createAudioPulse = Duration(milliseconds: 800);

  // Type PageView / swipe
  static const Duration createTypeSwipeDuration = Duration(milliseconds: 220);

  // Per-type editor layout
  static const double createMediaPreviewAspectRatio = 0.75; // 4:3 portrait
  static const double createStoryPreviewAspectRatio = 1.778; // 9:16
  static const double createArticleCoverHeight = 180;
  static const double createEventBannerHeight = 140;
  static const double createLiveThumbnailHeight = 160;
  static const double createAudioPlayerHeight = 80;
  static const double createPollOptionMinHeight = 48;
  static const double createEditorDividerThickness = 0.5;

  // Twitter-style composer
  static const double composerAvatarSize = avatarMediumSize;
  static const double composerThreadLineWidth = 1.5;
  static const double composerAttachBarHeight = 48;
  static const double composerTypeChipHeight = 32;
  static const double composerTypeChipSpacing = spaceXs;
  static const double composerTypeChipRadius = radiusPill;
  static const double composerAttachIconSize = 22;

  // ---------------------------------------------------------------------------
  // Camera / capture overlay
  // ---------------------------------------------------------------------------
  static const double createCameraOverlayAlpha = 0.45;
  static const double createCameraShutterBorderWidth = 3.0;
  static const double createTypeChipFontSize = 13.0;
  static const double createTypeChipIconSize = 14.0;
  static const double createTypeChipBorderWidth = 1.0;
  static const Duration createTypeChipAnimationDuration =
      Duration(milliseconds: 180);

  // Direct-editor CTA page
  static const double createDirectEditorIconSize = 56.0;
  static const double createDirectEditorLabelFontSize = 22.0;
  static const double createDirectEditorDescFontSize = 14.0;

  // Audio capture
  static const double createAudioRecorderIconScale = 0.45;
  static const double createMicIconScale = 0.5;
  static const double createMicPulseScaleAmplitude = 0.2;
  static const double createAudioHintFontSize = 14.0;
  static const double createAudioWaveBarMidHeight = 12.0;
  static const double createAudioWaveBarMinHeight = 8.0;
  static const double createAudioWaveBarRadius = 2.0;
  static const int createAudioWaveBarCount = 20;

  // Recording indicator
  static const double createRecordingDotSize = 10.0;
  static const double createRecordingLabelFontSize = 12.0;
  static const double createRecordingLabelLetterSpacing = 1.0;

  // Video shutter & editor
  static const double createVideoShutterRecordingScale = 0.4;
  static const double createVideoShutterRecordingRadius = 6.0;
  static const double createVideoPlayOverlaySize = 56.0;
  static const double createVideoPlayIconSize = 36.0;
  static const double createVideoThumbPlaceholderIconSize = 48.0;

  // Story
  static const double createStoryBadgeIconSize = 14.0;
  static const double createStoryBadgeFontSize = 12.0;
  static const int createStoryTextMaxLines = 3;

  // Carousel dots (photo editor)
  static const double createCarouselActiveDotWidth = 16.0;
  static const double createCarouselDotSize = 6.0;
  static const double createCarouselDotRadius = 3.0;

  // Editor fields / buttons
  static const int createPostBodyMinLines = 5;
  static const int createPhotoBodyMinLines = 2;
  static const int createAudioDescMinLines = 3;
  static const int createArticleBodyMinLines = 10;
  static const int createEventDescMinLines = 3;
  static const double createEditorButtonMinHeight = 48.0;
  static const double createEditorAppBarDividerHeight = 1.0;
  static const double createPublishProgressStrokeWidth = 2.0;
  static const int createArticleWpm = 200;

  // Shared icon sizes
  static const double createIconRowIconSize = 20.0;
  static const double createVisibilityIconSize = 16.0;
  static const double createEmptyMediaIconSize = 40.0;
  static const double createToolbarIconSize = 18.0;
  static const double createEditorInlineIconSize = 18.0;

  // Poll
  static const int createPollMinOptions = 2;
  static const int createPollMaxOptions = 4;
  static const double createPollIconSize = 18.0;

  // Event
  static const double createEventIconSize = 18.0;

  // Live badge
  static const double createLiveBadgeDotSize = 8.0;
  static const double createLiveBadgeFontSize = 10.0;
  static const double createLiveBadgeLetterSpacing = 1.0;
  static const double createLiveWarningIconSize = 18.0;

  // Schedule chip
  static const double createScheduleChipBorderWidth = 1.5;
  static const double createScheduleChipIconSize = 18.0;

  // Media badge (shared between picker sheet and preview strip)
  static const double mediaPickerBadgeIconSize = 12.0;
  static const double mediaPickerBadgePaddingVertical = 1.0;
  static const double mediaPickerBadgeFontSize = 10.0;

  // ---------------------------------------------------------------------------
  // Skeleton / Shimmer (PostsLoadStateView)
  // ---------------------------------------------------------------------------

  /// Duração do ciclo pulse do shimmer skeleton.
  static const Duration skeletonShimmerDuration = Duration(milliseconds: 900);

  /// Raio padrão das caixas skeleton.
  static const double skeletonBoxRadius = 6.0;

  /// Tamanho do círculo avatar no skeleton.
  static const double skeletonAvatarSize = 40.0;

  /// Altura das linhas de texto skeleton (corpo).
  static const double skeletonLineHeight = 14.0;

  /// Altura das linhas de texto skeleton (meta/subtítulo).
  static const double skeletonLineHeightSm = 10.0;

  /// Largura simulada do nome no header skeleton.
  static const double skeletonNameWidth = 120.0;

  /// Largura simulada do meta (tempo/seguindo) no header skeleton.
  static const double skeletonMetaWidth = 80.0;

  /// Largura da última linha de corpo (parcial, para naturalidade).
  static const double skeletonLastLineWidth = 180.0;

  /// Altura do placeholder de mídia (imagem) no skeleton.
  static const double skeletonMediaHeight = 180.0;

  /// Largura de cada ação de engajamento no rodapé skeleton.
  static const double skeletonActionWidth = 48.0;
}