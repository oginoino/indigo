import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../../model/party/user_profile.dart';
import '../../../model/post/post.dart';
import '../../../model/post/post_media.dart';
import '../../../util/const/app/app_strings.dart';
import '../../../util/const/ui/ui_constants.dart';
import '../../../util/formatter/post_time_formatter.dart';
import '../../theme/media_overlay_theme.dart';
import '../avatar.dart';
import '../post/post_media_load_error.dart';

class StoryViewer extends StatefulWidget {
  const StoryViewer({
    required this.stories,
    required this.authorFor,
    this.initialIndex = 0,
    this.seenStoryIds = const <String>{},
    this.onStorySeen,
    super.key,
  });

  final List<Post> stories;
  final UserProfile? Function(Post post) authorFor;
  final int initialIndex;
  final Set<String> seenStoryIds;
  final ValueChanged<Post>? onStorySeen;

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _progressController;
  late final Set<String> _seenStoryIds;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    final lastIndex = widget.stories.length - 1;
    _currentIndex = lastIndex < 0 ? 0 : widget.initialIndex.clamp(0, lastIndex);
    _seenStoryIds = {...widget.seenStoryIds};
    _pageController = PageController(initialPage: _currentIndex);
    _progressController = AnimationController(
      vsync: this,
      duration: UIConstants.storyViewerDisplayDuration,
    )..addStatusListener(_handleProgressStatus);

    if (widget.stories.isNotEmpty) {
      _progressController.forward();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _markSeen(_currentIndex);
        _precacheStoryAt(_currentIndex + 1);
      });
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _handleProgressStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) _advance();
  }

  /// Avança automaticamente pulando os stories já vistos, indo para o próximo
  /// story não visto do perfil atual (ou do próximo perfil). Fecha quando não
  /// restam stories não vistos.
  void _advance() {
    final nextIndex = _nextUnseenIndex(_currentIndex + 1);
    if (nextIndex == -1) {
      Navigator.of(context).maybePop();
      return;
    }
    _goToIndex(nextIndex);
  }

  /// Navegação manual para o próximo story, exibindo inclusive os já vistos.
  void _goToNext() {
    if (_currentIndex >= widget.stories.length - 1) {
      Navigator.of(context).maybePop();
      return;
    }
    _goToIndex(_currentIndex + 1);
  }

  void _goToPrevious() {
    if (_currentIndex <= 0) {
      _progressController.forward(from: 0);
      return;
    }
    _pageController.previousPage(
      duration: UIConstants.storyViewerTransitionDuration,
      curve: Curves.easeOut,
    );
  }

  void _goToIndex(int index) {
    if (index == _currentIndex + 1) {
      _pageController.nextPage(
        duration: UIConstants.storyViewerTransitionDuration,
        curve: Curves.easeOut,
      );
      return;
    }
    _pageController.jumpToPage(index);
  }

  int _nextUnseenIndex(int start) {
    for (var index = start; index < widget.stories.length; index++) {
      if (!_seenStoryIds.contains(widget.stories[index].id)) return index;
    }
    return -1;
  }

  /// Faixa contígua de stories do mesmo perfil que contém [index]. Como os
  /// stories são agrupados por perfil, o indicador de progresso reflete apenas
  /// os stories do perfil atual (um step por story, como no Instagram).
  ({int start, int count}) _profileRange(int index) {
    final authorRoleId = widget.stories[index].authorPartyRoleId;
    var start = index;
    while (start > 0 &&
        widget.stories[start - 1].authorPartyRoleId == authorRoleId) {
      start--;
    }
    var end = index;
    while (end + 1 < widget.stories.length &&
        widget.stories[end + 1].authorPartyRoleId == authorRoleId) {
      end++;
    }
    return (start: start, count: end - start + 1);
  }

  void _handlePageChanged(int index) {
    setState(() => _currentIndex = index);
    _progressController.forward(from: 0);
    _markSeen(index);
    _precacheStoryAt(index + 1);
  }

  void _markSeen(int index) {
    if (index < 0 || index >= widget.stories.length) return;
    final story = widget.stories[index];
    if (_seenStoryIds.add(story.id)) widget.onStorySeen?.call(story);
  }

  void _precacheStoryAt(int index) {
    if (!mounted || index < 0 || index >= widget.stories.length) return;
    final media = widget.stories[index].media;
    if (media.isEmpty) return;
    unawaited(
      precacheImage(
        NetworkImage(media.first.sourceUrl),
        context,
        onError: (error, stackTrace) {},
      ),
    );
  }

  void _handleTap(TapUpDetails details) {
    final width = MediaQuery.sizeOf(context).width;
    if (details.globalPosition.dx < width / 2) {
      _goToPrevious();
    } else {
      _goToNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stories.isEmpty) return const SizedBox.shrink();

    final mediaTheme = MediaOverlayTheme.of(context);
    final currentStory = widget.stories[_currentIndex];
    final author = widget.authorFor(currentStory);
    final profileRange = _profileRange(_currentIndex);

    return Scaffold(
      backgroundColor: mediaTheme.backgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.stories.length,
            onPageChanged: _handlePageChanged,
            itemBuilder: (context, index) {
              final story = widget.stories[index];
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: _handleTap,
                child: _StoryPage(
                  story: story,
                  author: widget.authorFor(story),
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.topCenter,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.storyViewerHorizontalPadding,
                  vertical: UIConstants.storyViewerTopPadding,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StoryProgressBars(
                      count: profileRange.count,
                      currentIndex: _currentIndex - profileRange.start,
                      progress: _progressController,
                    ),
                    const SizedBox(
                      height: UIConstants.storyViewerHeaderSpacing,
                    ),
                    _StoryHeader(
                      author: author,
                      publishedAt: currentStory.createdAt,
                      onClose: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryPage extends StatelessWidget {
  const _StoryPage({required this.story, required this.author});

  final Post story;
  final UserProfile? author;

  @override
  Widget build(BuildContext context) {
    final mediaTheme = MediaOverlayTheme.of(context);
    final media = story.media.isEmpty ? null : story.media.first;
    final caption = story.content.plainText;

    return ColoredBox(
      color: mediaTheme.backgroundColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (media != null)
            _StoryImage(media: media, semanticLabel: media.altText)
          else
            Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                size: UIConstants.storyViewerFallbackIconSize,
                color: mediaTheme.secondaryForegroundColor,
              ),
            ),
          if (caption.isNotEmpty)
            Align(
              alignment: Alignment.bottomCenter,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      mediaTheme.gradientBottomColor,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    UIConstants.storyViewerHorizontalPadding,
                    UIConstants.storyViewerCaptionSpacing,
                    UIConstants.storyViewerHorizontalPadding,
                    UIConstants.storyViewerCaptionBottomPadding,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      caption,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: mediaTheme.foregroundColor,
                        shadows: UIConstants.postMediaTextShadows,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StoryImage extends StatefulWidget {
  const _StoryImage({required this.media, this.semanticLabel});

  final PostMedia media;
  final String? semanticLabel;

  @override
  State<_StoryImage> createState() => _StoryImageState();
}

class _StoryImageState extends State<_StoryImage> {
  int _requestVersion = 0;
  bool _usingFallbackSource = false;

  void _retryImage() {
    setState(() {
      _usingFallbackSource =
          widget.media.thumbnailUrl != null && !_usingFallbackSource;
      _requestVersion++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaTheme = MediaOverlayTheme.of(context);
    final sourceUrl = _usingFallbackSource
        ? widget.media.thumbnailUrl!
        : widget.media.sourceUrl;

    return Image.network(
      sourceUrl,
      key: ValueKey(_requestVersion),
      fit: BoxFit.cover,
      semanticLabel: widget.semanticLabel,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Center(
          child: CircularProgressIndicator(color: mediaTheme.foregroundColor),
        );
      },
      errorBuilder: (context, error, stackTrace) => PostMediaLoadError(
        message: AppStrings.imageLoadFailed,
        icon: Icons.broken_image_outlined,
        onDarkBackground: true,
        onRetry: _retryImage,
      ),
    );
  }
}

class _StoryProgressBars extends StatelessWidget {
  const _StoryProgressBars({
    required this.count,
    required this.currentIndex,
    required this.progress,
  });

  final int count;
  final int currentIndex;
  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    final mediaTheme = MediaOverlayTheme.of(context);
    final trackColor = mediaTheme.foregroundColor.withValues(
      alpha: UIConstants.storyViewerProgressTrackOpacity,
    );
    final counter = AppStrings.storyViewerCounter
        .replaceAll('{current}', '${currentIndex + 1}')
        .replaceAll('{total}', '$count');

    return Semantics(
      label: counter,
      child: Row(
        children: [
          for (var index = 0; index < count; index++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.storyViewerProgressSpacing / 2,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    UIConstants.storyViewerProgressRadius,
                  ),
                  child: SizedBox(
                    height: UIConstants.storyViewerProgressHeight,
                    child: index == currentIndex
                        ? AnimatedBuilder(
                            animation: progress,
                            builder: (context, _) => LinearProgressIndicator(
                              value: progress.value,
                              backgroundColor: trackColor,
                              valueColor: AlwaysStoppedAnimation(
                                mediaTheme.foregroundColor,
                              ),
                              minHeight: UIConstants.storyViewerProgressHeight,
                            ),
                          )
                        : LinearProgressIndicator(
                            value: index < currentIndex ? 1 : 0,
                            backgroundColor: trackColor,
                            valueColor: AlwaysStoppedAnimation(
                              mediaTheme.foregroundColor,
                            ),
                            minHeight: UIConstants.storyViewerProgressHeight,
                          ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StoryHeader extends StatelessWidget {
  const _StoryHeader({
    required this.author,
    required this.publishedAt,
    required this.onClose,
  });

  final UserProfile? author;
  final DateTime publishedAt;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaTheme = MediaOverlayTheme.of(context);
    final avatarUrl = author?.avatarUrl;
    final displayName = author?.displayName ?? AppStrings.unknownPostAuthor;

    return Row(
      children: [
        Avatar(
          diameter: UIConstants.storyViewerAvatarSize,
          imageProvider: avatarUrl == null || avatarUrl.isEmpty
              ? null
              : NetworkImage(avatarUrl),
          useSavedImage: false,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: mediaTheme.foregroundColor,
              width: UIConstants.postMediaBorderWidth,
            ),
          ),
        ),
        const SizedBox(width: UIConstants.storyViewerHeaderSpacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: mediaTheme.foregroundColor,
                  shadows: UIConstants.postMediaTextShadows,
                ),
              ),
              const SizedBox(height: UIConstants.postHeaderTextSpacing),
              Text(
                PostTimeFormatter.formatRelative(publishedAt),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: mediaTheme.secondaryForegroundColor,
                  shadows: UIConstants.postMediaTextShadows,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: AppStrings.closeStoryViewer,
          onPressed: onClose,
          style: IconButton.styleFrom(
            backgroundColor: mediaTheme.controlBackgroundColor,
            foregroundColor: mediaTheme.foregroundColor,
          ),
          icon: const Icon(
            Icons.close,
            size: UIConstants.storyViewerCloseIconSize,
          ),
        ),
      ],
    );
  }
}
