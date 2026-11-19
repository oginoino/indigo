import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../model/party/user_profile.dart';
import '../../../model/post/post.dart';
import '../../../model/post/post_media.dart';
import '../../../route/routes.dart';
import '../../../util/const/app/app_strings.dart';
import '../../../util/const/ui/ui_constants.dart';
import '../../theme/media_overlay_theme.dart';
import 'fullscreen_post_layout.dart';
import 'post_audio_player.dart';
import 'post_engagement_bar.dart';
import 'post_media_information.dart';
import 'post_media_load_error.dart';

class PostMediaGallery extends StatelessWidget {
  const PostMediaGallery({required this.post, required this.author, super.key});

  final Post post;
  final UserProfile? author;

  @override
  Widget build(BuildContext context) {
    final media = post.media;
    if (media.isEmpty) return const SizedBox.shrink();

    final children = <Widget>[];
    var index = 0;
    var imageOffset = 0;

    while (index < media.length) {
      if (media[index].isAudio) {
        children.add(PostAudioPlayer(media: media[index]));
        index++;
        continue;
      }
      if (media[index].isVideo) {
        children.add(_VideoPreview(postId: post.id, media: media[index]));
        index++;
        continue;
      }

      final photos = <PostMedia>[];
      while (index < media.length && media[index].isVisual) {
        photos.add(media[index]);
        index++;
      }
      children.add(
        _PhotoCollection(
          post: post,
          author: author,
          media: photos,
          collectionOffset: imageOffset,
        ),
      );
      imageOffset += photos.length;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final child in children)
          Padding(
            padding: const EdgeInsets.only(top: UIConstants.postCardSpacing),
            child: child,
          ),
      ],
    );
  }
}

class _PhotoCollection extends StatelessWidget {
  const _PhotoCollection({
    required this.post,
    required this.author,
    required this.media,
    required this.collectionOffset,
  });

  final Post post;
  final UserProfile? author;
  final List<PostMedia> media;
  final int collectionOffset;

  @override
  Widget build(BuildContext context) {
    final visibleCount = media.length > UIConstants.postPhotoGridCapacity
        ? UIConstants.postPhotoGridCapacity
        : media.length;

    if (media.length == 1) {
      return AspectRatio(
        aspectRatio: UIConstants.postMediaAspectRatio,
        child: _photoTile(context, 0),
      );
    }
    if (media.length == 2) {
      return AspectRatio(
        aspectRatio: UIConstants.postPhotoPairAspectRatio,
        child: Row(
          children: [
            Expanded(child: _photoTile(context, 0)),
            const SizedBox(width: UIConstants.postPhotoGridSpacing),
            Expanded(child: _photoTile(context, 1)),
          ],
        ),
      );
    }
    if (media.length == 3) {
      return AspectRatio(
        aspectRatio: UIConstants.postPhotoGridAspectRatio,
        child: Row(
          children: [
            Expanded(child: _photoTile(context, 0)),
            const SizedBox(width: UIConstants.postPhotoGridSpacing),
            Expanded(
              child: Column(
                children: [
                  Expanded(child: _photoTile(context, 1)),
                  const SizedBox(height: UIConstants.postPhotoGridSpacing),
                  Expanded(child: _photoTile(context, 2)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return AspectRatio(
      aspectRatio: UIConstants.postPhotoGridAspectRatio,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: visibleCount,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: UIConstants.postPhotoGridColumns,
          crossAxisSpacing: UIConstants.postPhotoGridSpacing,
          mainAxisSpacing: UIConstants.postPhotoGridSpacing,
        ),
        itemBuilder: (context, index) => _photoTile(
          context,
          index,
          remainingCount: index == visibleCount - 1
              ? media.length - visibleCount
              : 0,
        ),
      ),
    );
  }

  Widget _photoTile(BuildContext context, int index, {int remainingCount = 0}) {
    final photo = media[index];
    final label = photo.altText?.isNotEmpty == true
        ? photo.altText!
        : AppStrings.viewPostImage.replaceAll(
            '{index}',
            '${collectionOffset + index + 1}',
          );
    final heroTag = '${post.id}-${photo.id}';
    final mediaTheme = MediaOverlayTheme.of(context);

    return Tooltip(
      message: label,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(UIConstants.postMediaRadius),
        child: Material(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: InkWell(
            onTap: () => _openViewer(context, index),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: heroTag,
                  child: _NetworkPhoto(
                    media: photo,
                    fit: BoxFit.cover,
                    sourceUrl: photo.thumbnailUrl,
                    fallbackSourceUrl: photo.thumbnailUrl == null
                        ? null
                        : photo.sourceUrl,
                    semanticLabel: label,
                  ),
                ),
                if (remainingCount > 0)
                  ColoredBox(
                    color: mediaTheme.controlBackgroundColor,
                    child: Center(
                      child: Text(
                        '+$remainingCount',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(color: mediaTheme.foregroundColor),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openViewer(BuildContext context, int index) {
    Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        opaque: true,
        transitionDuration: UIConstants.imageViewerTransitionDuration,
        pageBuilder: (context, animation, secondaryAnimation) =>
            _FullscreenPhotoViewer(
              post: post,
              author: author,
              media: media,
              initialIndex: index,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }
}

class _FullscreenPhotoViewer extends StatefulWidget {
  const _FullscreenPhotoViewer({
    required this.post,
    required this.author,
    required this.media,
    required this.initialIndex,
  });

  final Post post;
  final UserProfile? author;
  final List<PostMedia> media;
  final int initialIndex;

  @override
  State<_FullscreenPhotoViewer> createState() => _FullscreenPhotoViewerState();
}

class _FullscreenPhotoViewerState extends State<_FullscreenPhotoViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaTheme = MediaOverlayTheme.of(context);
    final counter = AppStrings.imageViewerCounter
        .replaceAll('{current}', '${_currentIndex + 1}')
        .replaceAll('{total}', '${widget.media.length}');

    return Scaffold(
      backgroundColor: mediaTheme.backgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.media.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              final photo = widget.media[index];
              return Center(
                child: Hero(
                  tag: '${widget.post.id}-${photo.id}',
                  child: _NetworkPhoto(
                    media: photo,
                    fit: BoxFit.contain,
                    semanticLabel: photo.altText,
                    loadingColor: mediaTheme.foregroundColor,
                    onDarkBackground: true,
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.postCardSpacing),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: AppStrings.closeImageViewer,
                      onPressed: () => Navigator.of(context).pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: mediaTheme.controlBackgroundColor,
                        foregroundColor: mediaTheme.foregroundColor,
                      ),
                      icon: const Icon(Icons.close),
                    ),
                    const Spacer(),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: mediaTheme.controlBackgroundColor,
                        borderRadius: BorderRadius.circular(
                          UIConstants.postMediaRadius,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: UIConstants.postCardSpacing,
                          vertical: UIConstants.postCardSpacing / 2,
                        ),
                        child: Text(
                          counter,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: mediaTheme.foregroundColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isLandscape = FullscreenPostLayout.isLandscape(
                    constraints,
                  );
                  final actionRailWidth = FullscreenPostLayout.actionRailWidth(
                    constraints,
                  );

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(
                      UIConstants.videoOverlayPadding,
                      UIConstants.videoOverlayPadding,
                      UIConstants.fullscreenEngagementRightInset,
                      UIConstants.videoOverlayPadding,
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: IgnorePointer(
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
                            ),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: PostMediaInformation(
                                post: widget.post,
                                author: widget.author,
                              ),
                            ),
                            const SizedBox(
                              width:
                                  UIConstants.fullscreenOverlayContentSpacing,
                            ),
                            SizedBox(
                              width: actionRailWidth,
                              child: PostEngagementBar(
                                post: widget.post,
                                layout: isLandscape
                                    ? PostEngagementLayout.horizontal
                                    : PostEngagementLayout.vertical,
                                onMedia: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoPreview extends StatelessWidget {
  const _VideoPreview({required this.postId, required this.media});

  final String postId;
  final PostMedia media;

  @override
  Widget build(BuildContext context) {
    final mediaTheme = MediaOverlayTheme.of(context);

    return Tooltip(
      message: AppStrings.playVideo,
      child: AspectRatio(
        aspectRatio: UIConstants.postMediaAspectRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(UIConstants.postMediaRadius),
          child: Material(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: InkWell(
              onTap: () => context.go(
                Uri(
                  path: Routes.videos,
                  queryParameters: {
                    Routes.videoPostIdQueryParameter: postId,
                    Routes.videoMediaIdQueryParameter: media.id,
                  },
                ).toString(),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (media.thumbnailUrl case final thumbnailUrl?)
                    Positioned.fill(
                      child: _NetworkPhoto(
                        media: media,
                        fit: BoxFit.cover,
                        sourceUrl: thumbnailUrl,
                        semanticLabel: media.altText,
                      ),
                    ),
                  Icon(
                    Icons.play_circle_fill,
                    color: mediaTheme.foregroundColor,
                    size: UIConstants.videoActionIconSize * 2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NetworkPhoto extends StatefulWidget {
  const _NetworkPhoto({
    required this.media,
    required this.fit,
    this.sourceUrl,
    this.fallbackSourceUrl,
    this.semanticLabel,
    this.loadingColor,
    this.onDarkBackground = false,
  });

  final PostMedia media;
  final BoxFit fit;
  final String? sourceUrl;
  final String? fallbackSourceUrl;
  final String? semanticLabel;
  final Color? loadingColor;
  final bool onDarkBackground;

  @override
  State<_NetworkPhoto> createState() => _NetworkPhotoState();
}

class _NetworkPhotoState extends State<_NetworkPhoto> {
  int _requestVersion = 0;
  bool _usingFallbackSource = false;

  @override
  void didUpdateWidget(covariant _NetworkPhoto oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.media.sourceUrl == widget.media.sourceUrl &&
        oldWidget.sourceUrl == widget.sourceUrl &&
        oldWidget.fallbackSourceUrl == widget.fallbackSourceUrl) {
      return;
    }

    _usingFallbackSource = false;
    _requestVersion++;
  }

  void _retryImage() {
    setState(() {
      _usingFallbackSource =
          widget.fallbackSourceUrl != null && !_usingFallbackSource;
      _requestVersion++;
    });
  }

  @override
  Widget build(BuildContext context) => Image.network(
    _usingFallbackSource
        ? widget.fallbackSourceUrl!
        : widget.sourceUrl ?? widget.media.sourceUrl,
    key: ValueKey(_requestVersion),
    fit: widget.fit,
    semanticLabel: widget.semanticLabel,
    loadingBuilder: (context, child, progress) {
      if (progress == null) return child;
      return Center(
        child: CircularProgressIndicator(
          color: widget.loadingColor ?? Theme.of(context).colorScheme.primary,
        ),
      );
    },
    errorBuilder: (context, error, stackTrace) => PostMediaLoadError(
      message: AppStrings.imageLoadFailed,
      icon: Icons.broken_image_outlined,
      onRetry: _retryImage,
      onDarkBackground: widget.onDarkBackground,
    ),
  );
}
