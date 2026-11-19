import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../model/party/user_profile.dart';
import '../../model/post/post.dart';
import '../../provider/post/posts_provider.dart';
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
  const VideosPage({super.key});

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

          return _VideoCarousel(items: videos, authorFor: provider.authorFor);
        },
      ),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}

class _VideoCarousel extends StatefulWidget {
  const _VideoCarousel({required this.items, required this.authorFor});

  final List<VideoFeedItem> items;
  final UserProfile? Function(Post post) authorFor;

  @override
  State<_VideoCarousel> createState() => _VideoCarouselState();
}

class _VideoCarouselState extends State<_VideoCarousel> {
  int _currentIndex = 0;
  final Map<String, _VideoControllerEntry> _controllers = {};

  @override
  void initState() {
    super.initState();
    _syncControllerWindow();
  }

  @override
  void didUpdateWidget(covariant _VideoCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (identical(oldWidget.items, widget.items)) return;

    if (_currentIndex >= widget.items.length) {
      _currentIndex = widget.items.isEmpty ? 0 : widget.items.length - 1;
    }
    _syncControllerWindow();
  }

  String _keyFor(VideoFeedItem item) => '${item.post.id}:${item.media.id}';

  _VideoControllerEntry _ensureController(int index) {
    final item = widget.items[index];
    final key = _keyFor(item);
    final existing = _controllers[key];
    if (existing != null && existing.sourceUrl == item.media.sourceUrl) {
      return existing;
    }

    existing?.dispose();
    final entry = _VideoControllerEntry(item.media.sourceUrl);
    _controllers[key] = entry;
    entry.initialization.then<void>(
      (_) {
        if (!mounted ||
            _currentIndex >= widget.items.length ||
            _keyFor(widget.items[_currentIndex]) != key ||
            !identical(_controllers[key], entry)) {
          return;
        }
        _playController(entry.controller);
      },
      onError: (Object error, StackTrace stackTrace) {
        ErrorHandler.report(
          error,
          stackTrace,
          message: AppStrings.videoPlaybackFailed,
        );
      },
    );
    return entry;
  }

  void _syncControllerWindow() {
    if (widget.items.isEmpty) {
      for (final entry in _controllers.values) {
        entry.dispose();
      }
      _controllers.clear();
      return;
    }

    final firstIndex = _currentIndex > 0 ? _currentIndex - 1 : 0;
    final lastIndex = _currentIndex + 1 < widget.items.length
        ? _currentIndex + 1
        : widget.items.length - 1;
    final retainedKeys = <String>{};

    for (var index = firstIndex; index <= lastIndex; index++) {
      final item = widget.items[index];
      retainedKeys.add(_keyFor(item));
      _ensureController(index);
    }

    final expiredKeys = _controllers.keys
        .where((key) => !retainedKeys.contains(key))
        .toList(growable: false);
    for (final key in expiredKeys) {
      _controllers.remove(key)?.dispose();
    }
  }

  void _handlePageChanged(int index) {
    setState(() => _currentIndex = index);
    _syncControllerWindow();

    final entry = _controllers[_keyFor(widget.items[index])];
    if (entry != null) _playController(entry.controller);
  }

  void _retryController(String key) {
    final index = widget.items.indexWhere((item) => _keyFor(item) == key);
    if (index < 0) return;

    _controllers.remove(key)?.dispose();
    setState(_syncControllerWindow);
  }

  @override
  void dispose() {
    for (final entry in _controllers.values) {
      entry.dispose();
    }
    _controllers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: widget.items.length,
      onPageChanged: _handlePageChanged,
      itemBuilder: (context, index) {
        if ((index - _currentIndex).abs() > 1) {
          return const SizedBox.expand();
        }
        final item = widget.items[index];
        final key = _keyFor(item);
        final entry = _ensureController(index);
        return _FullscreenVideoItem(
          key: ValueKey(key),
          item: item,
          author: widget.authorFor(item.post),
          entry: entry,
          isActive: index == _currentIndex,
          onRetry: () => _retryController(key),
        );
      },
    );
  }
}

class _VideoControllerEntry {
  _VideoControllerEntry(this.sourceUrl)
    : controller = VideoPlayerController.networkUrl(Uri.parse(sourceUrl)) {
    initialization = _initialize();
  }

  final String sourceUrl;
  final VideoPlayerController controller;
  late final Future<void> initialization;
  bool _isDisposed = false;

  Future<void> _initialize() async {
    await controller.initialize();
    await controller.setLooping(true);
  }

  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;

    final release = initialization.then<void>(
      (_) => controller.dispose(),
      onError: (Object error, StackTrace stackTrace) => controller.dispose(),
    );
    unawaited(
      release.catchError((Object error, StackTrace stackTrace) {
        ErrorHandler.report(error, stackTrace);
      }),
    );
  }
}

void _playController(VideoPlayerController controller) {
  if (!controller.value.isInitialized || controller.value.isPlaying) return;
  unawaited(
    controller.play().catchError((Object error, StackTrace stackTrace) {
      ErrorHandler.report(
        error,
        stackTrace,
        message: AppStrings.videoPlaybackFailed,
      );
    }),
  );
}

void _pauseController(VideoPlayerController controller) {
  if (!controller.value.isInitialized || !controller.value.isPlaying) return;
  unawaited(
    controller.pause().catchError((Object error, StackTrace stackTrace) {
      ErrorHandler.report(
        error,
        stackTrace,
        message: AppStrings.videoPlaybackFailed,
      );
    }),
  );
}

class _FullscreenVideoItem extends StatefulWidget {
  const _FullscreenVideoItem({
    super.key,
    required this.item,
    required this.author,
    required this.entry,
    required this.isActive,
    required this.onRetry,
  });

  final VideoFeedItem item;
  final UserProfile? author;
  final _VideoControllerEntry entry;
  final bool isActive;
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

    if (oldWidget.isActive == widget.isActive) return;
    if (!_controller.value.isInitialized) return;
    if (widget.isActive) {
      _playController(_controller);
    } else {
      _pauseController(_controller);
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
