import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../model/party/user_profile.dart';
import '../../model/post/post.dart';
import '../../provider/post/posts_provider.dart';
import '../../service/video_playback_manager.dart';
import '../../util/const/app/app_strings.dart';
import '../../util/const/ui/ui_constants.dart';
import '../../util/log/error_handler.dart';
import '../components/app_bottom_navigation_bar.dart';
import '../components/post/fullscreen_post_layout.dart';
import '../components/post/post_engagement_bar.dart';
import '../components/post/post_media_load_error.dart';
import '../components/post/post_media_information.dart';
import '../theme/media_overlay_theme.dart';

class VideosPage extends StatelessWidget {
  const VideosPage({this.initialPostId, this.initialMediaId, super.key});

  final String? initialPostId;
  final String? initialMediaId;

  @override
  Widget build(BuildContext context) {
    final mediaTheme = MediaOverlayTheme.of(context);

    return Scaffold(
      backgroundColor: mediaTheme.backgroundColor,
      extendBody: true,
      body: Consumer<PostsProvider>(
        builder: (context, provider, _) {
          if (provider.status == PostsLoadStatus.loading ||
              provider.status == PostsLoadStatus.initial) {
            return Center(
              child: CircularProgressIndicator(
                color: mediaTheme.foregroundColor,
              ),
            );
          }
          if (provider.status == PostsLoadStatus.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.postsLoadFailed,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: mediaTheme.foregroundColor),
                  ),
                  TextButton(
                    onPressed: provider.load,
                    child: const Text(AppStrings.retry),
                  ),
                ],
              ),
            );
          }

          final videos = provider.videoFeedItems;
          if (videos.isEmpty) {
            return Center(
              child: Text(
                AppStrings.noVideosAvailable,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: mediaTheme.foregroundColor),
              ),
            );
          }

          return _VideoCarousel(
            items: videos,
            authorFor: provider.authorFor,
            initialPostId: initialPostId,
            initialMediaId: initialMediaId,
          );
        },
      ),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}

class _VideoCarousel extends StatefulWidget {
  const _VideoCarousel({
    required this.items,
    required this.authorFor,
    this.initialPostId,
    this.initialMediaId,
  });

  final List<VideoFeedItem> items;
  final UserProfile? Function(Post post) authorFor;
  final String? initialPostId;
  final String? initialMediaId;

  @override
  State<_VideoCarousel> createState() => _VideoCarouselState();
}

class _VideoCarouselState extends State<_VideoCarousel> {
  late final VideoPlaybackManager _playbackManager;
  late final PageController _pageController;

  int _initialVideoIndex() {
    final postId = widget.initialPostId;
    final mediaId = widget.initialMediaId;
    if (postId == null || mediaId == null) return 0;

    final index = widget.items.indexWhere(
      (item) => item.post.id == postId && item.media.id == mediaId,
    );
    return index < 0 ? 0 : index;
  }

  @override
  void initState() {
    super.initState();
    final initialIndex = _initialVideoIndex();
    _pageController = PageController(initialPage: initialIndex);
    _playbackManager = VideoPlaybackManager(
      initialIndex: initialIndex,
      onError: (error, stackTrace) => ErrorHandler.report(
        error,
        stackTrace,
        message: AppStrings.videoPlaybackFailed,
      ),
    )..updateSources(_sourcesFor(widget.items));
  }

  @override
  void didUpdateWidget(covariant _VideoCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (identical(oldWidget.items, widget.items)) return;
    _playbackManager.updateSources(_sourcesFor(widget.items));
  }

  void _handlePageChanged(int index) {
    setState(() => _playbackManager.setCurrentIndex(index));
  }

  void _retryController(String id) =>
      setState(() => _playbackManager.retry(id));

  List<VideoPlaybackSource> _sourcesFor(List<VideoFeedItem> items) => [
    for (final item in items)
      VideoPlaybackSource(
        id: '${item.post.id}:${item.media.id}',
        sourceUrl: item.media.sourceUrl,
      ),
  ];

  @override
  void dispose() {
    _playbackManager.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: widget.items.length + 1,
      onPageChanged: _handlePageChanged,
      itemBuilder: (context, index) {
        if (index == widget.items.length) {
          return const _VideosEndMessage();
        }
        if (!_playbackManager.isWithinPreloadWindow(index)) {
          return const SizedBox.expand();
        }
        final item = widget.items[index];
        final id = '${item.post.id}:${item.media.id}';
        final entry = _playbackManager.entryAt(index);
        return _FullscreenVideoItem(
          key: ValueKey(id),
          item: item,
          author: widget.authorFor(item.post),
          entry: entry,
          onRetry: () => _retryController(id),
        );
      },
    );
  }
}

class _VideosEndMessage extends StatelessWidget {
  const _VideosEndMessage();

  @override
  Widget build(BuildContext context) {
    final mediaTheme = MediaOverlayTheme.of(context);
    return Center(
      child: Text(
        AppStrings.videosEndReached,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: mediaTheme.foregroundColor),
      ),
    );
  }
}

class _FullscreenVideoItem extends StatefulWidget {
  const _FullscreenVideoItem({
    super.key,
    required this.item,
    required this.author,
    required this.entry,
    required this.onRetry,
  });

  final VideoFeedItem item;
  final UserProfile? author;
  final VideoPlaybackEntry entry;
  final VoidCallback onRetry;

  @override
  State<_FullscreenVideoItem> createState() => _FullscreenVideoItemState();
}

class _FullscreenVideoItemState extends State<_FullscreenVideoItem> {
  bool _isMuted = false;
  Object? _playbackError;

  VideoPlayerController get _controller => widget.entry.controller;

  @override
  void didUpdateWidget(covariant _FullscreenVideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.entry, widget.entry)) {
      _isMuted = false;
      _playbackError = null;
    }
  }

  void _retryInitialization() => widget.onRetry();

  Future<void> _togglePlayback() async {
    try {
      if (_controller.value.isPlaying) {
        await _controller.pause();
      } else {
        await _controller.play();
      }
      if (mounted) setState(() {});
    } catch (error, stackTrace) {
      ErrorHandler.report(
        error,
        stackTrace,
        message: AppStrings.videoPlaybackFailed,
      );
      if (mounted) setState(() => _playbackError = error);
    }
  }

  Widget _buildPlaybackButton(Color foregroundColor) => IconButton(
    tooltip: _controller.value.isPlaying
        ? AppStrings.pauseVideo
        : AppStrings.playVideo,
    onPressed: _togglePlayback,
    color: foregroundColor,
    icon: Icon(
      _controller.value.isPlaying ? Icons.pause_circle : Icons.play_circle,
      size: UIConstants.videoActionIconSize,
    ),
  );

  Widget _buildMuteButton(Color foregroundColor) => IconButton(
    tooltip: _isMuted ? AppStrings.unmuteVideo : AppStrings.muteVideo,
    onPressed: _toggleMute,
    color: foregroundColor,
    icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up),
  );

  Future<void> _toggleMute() async {
    final isMuted = !_isMuted;
    try {
      await _controller.setVolume(isMuted ? 0 : 1);
      if (mounted) setState(() => _isMuted = isMuted);
    } catch (error, stackTrace) {
      ErrorHandler.report(
        error,
        stackTrace,
        message: AppStrings.videoPlaybackFailed,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaTheme = MediaOverlayTheme.of(context);

    return FutureBuilder<void>(
      key: ObjectKey(widget.entry),
      future: widget.entry.initialization,
      builder: (context, snapshot) {
        if (_playbackError != null) {
          return PostMediaLoadError(
            message: AppStrings.videoPlaybackFailed,
            icon: Icons.video_file_outlined,
            onDarkBackground: true,
            onRetry: _retryInitialization,
          );
        }
        if (snapshot.hasError) {
          return PostMediaLoadError(
            message: AppStrings.videoPlaybackFailed,
            icon: Icons.video_file_outlined,
            onDarkBackground: true,
            onRetry: _retryInitialization,
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(
            child: CircularProgressIndicator(color: mediaTheme.foregroundColor),
          );
        }

        final size = _controller.value.size;
        return GestureDetector(
          onTap: _togglePlayback,
          child: Stack(
            fit: StackFit.expand,
            children: [
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: size.width,
                  height: size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0, UIConstants.videoOverlayGradientMiddleStop, 1],
                      colors: [
                        mediaTheme.gradientTopColor,
                        Colors.transparent,
                        mediaTheme.gradientBottomColor,
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isLandscape = FullscreenPostLayout.isLandscape(
                      constraints,
                    );
                    final actionRailWidth =
                        FullscreenPostLayout.actionRailWidth(constraints);

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(
                        UIConstants.videoOverlayPadding,
                        UIConstants.videoOverlayPadding,
                        UIConstants.fullscreenEngagementRightInset,
                        UIConstants.fullscreenVideoBottomGap,
                      ),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {},
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: PostMediaInformation(
                                post: widget.item.post,
                                author: widget.author,
                              ),
                            ),
                            const SizedBox(
                              width:
                                  UIConstants.fullscreenOverlayContentSpacing,
                            ),
                            SizedBox(
                              width: actionRailWidth,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  PostEngagementBar(
                                    post: widget.item.post,
                                    layout: isLandscape
                                        ? PostEngagementLayout.horizontal
                                        : PostEngagementLayout.vertical,
                                    onMedia: true,
                                  ),
                                  const SizedBox(
                                    height:
                                        UIConstants.fullscreenEngagementSpacing,
                                  ),
                                  if (isLandscape)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        _buildPlaybackButton(
                                          mediaTheme.foregroundColor,
                                        ),
                                        _buildMuteButton(
                                          mediaTheme.foregroundColor,
                                        ),
                                      ],
                                    )
                                  else ...[
                                    _buildPlaybackButton(
                                      mediaTheme.foregroundColor,
                                    ),
                                    _buildMuteButton(
                                      mediaTheme.foregroundColor,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
