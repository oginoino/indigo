import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../model/party/user_profile.dart';
import '../../model/post/post.dart';
import '../../provider/post/posts_provider.dart';
import '../../util/const/app/app_strings.dart';
import '../../util/const/ui/ui_constants.dart';
import '../components/app_bottom_navigation_bar.dart';
import '../components/post/post_engagement_bar.dart';
import '../components/post/post_media_load_error.dart';
import '../components/post/post_media_information.dart';

class VideosPage extends StatelessWidget {
  const VideosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      body: Consumer<PostsProvider>(
        builder: (context, provider, _) {
          if (provider.status == PostsLoadStatus.loading ||
              provider.status == PostsLoadStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.status == PostsLoadStatus.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    AppStrings.postsLoadFailed,
                    style: TextStyle(color: Colors.white),
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
            return const Center(
              child: Text(
                AppStrings.noVideosAvailable,
                style: TextStyle(color: Colors.white),
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

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: widget.items.length,
      onPageChanged: (index) => setState(() => _currentIndex = index),
      itemBuilder: (context, index) => _FullscreenVideoItem(
        item: widget.items[index],
        author: widget.authorFor(widget.items[index].post),
        isActive: index == _currentIndex,
      ),
    );
  }
}

class _FullscreenVideoItem extends StatefulWidget {
  const _FullscreenVideoItem({
    required this.item,
    required this.author,
    required this.isActive,
  });

  final VideoFeedItem item;
  final UserProfile? author;
  final bool isActive;

  @override
  State<_FullscreenVideoItem> createState() => _FullscreenVideoItemState();
}

class _FullscreenVideoItemState extends State<_FullscreenVideoItem> {
  late VideoPlayerController _controller;
  late Future<void> _initialization;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _createController();
  }

  void _createController() {
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.item.media.sourceUrl),
    );
    _initialization = _initialize();
  }

  Future<void> _initialize() async {
    await _controller.initialize();
    await _controller.setLooping(true);
    if (widget.isActive) await _controller.play();
  }

  @override
  void didUpdateWidget(covariant _FullscreenVideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.media.sourceUrl != widget.item.media.sourceUrl) {
      final previousController = _controller;
      _isMuted = false;
      _createController();
      unawaited(previousController.dispose());
      return;
    }

    if (oldWidget.isActive == widget.isActive) return;
    if (!_controller.value.isInitialized) return;
    if (widget.isActive) {
      unawaited(_controller.play());
    } else {
      unawaited(_controller.pause());
    }
  }

  void _retryInitialization() {
    final previousController = _controller;
    setState(() {
      _isMuted = false;
      _createController();
    });
    unawaited(previousController.dispose());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (_controller.value.isPlaying) {
      await _controller.pause();
    } else {
      await _controller.play();
    }
    if (mounted) setState(() {});
  }

  Future<void> _toggleMute() async {
    _isMuted = !_isMuted;
    await _controller.setVolume(_isMuted ? 0 : 1);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return PostMediaLoadError(
            message: AppStrings.videoPlaybackFailed,
            icon: Icons.video_file_outlined,
            onDarkBackground: true,
            onRetry: _retryInitialization,
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
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
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0, 0.4, 1],
                      colors: [
                        Colors.black38,
                        Colors.transparent,
                        Colors.black87,
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    UIConstants.videoOverlayPadding,
                    UIConstants.videoOverlayPadding,
                    UIConstants.videoOverlayPadding,
                    UIConstants.fullscreenVideoBottomInset,
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
                          width: UIConstants.fullscreenOverlayContentSpacing,
                        ),
                        SizedBox(
                          width: UIConstants.fullscreenEngagementRailWidth,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PostEngagementBar(
                                post: widget.item.post,
                                layout: PostEngagementLayout.vertical,
                                onMedia: true,
                              ),
                              const SizedBox(
                                height: UIConstants.fullscreenEngagementSpacing,
                              ),
                              IconButton(
                                tooltip: _controller.value.isPlaying
                                    ? AppStrings.pauseVideo
                                    : AppStrings.playVideo,
                                onPressed: _togglePlayback,
                                color: Colors.white,
                                icon: Icon(
                                  _controller.value.isPlaying
                                      ? Icons.pause_circle
                                      : Icons.play_circle,
                                  size: UIConstants.videoActionIconSize,
                                ),
                              ),
                              IconButton(
                                tooltip: _isMuted
                                    ? AppStrings.unmuteVideo
                                    : AppStrings.muteVideo,
                                onPressed: _toggleMute,
                                color: Colors.white,
                                icon: Icon(
                                  _isMuted ? Icons.volume_off : Icons.volume_up,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
