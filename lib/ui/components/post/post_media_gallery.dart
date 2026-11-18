import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../model/post/post_media.dart';
import '../../../route/routes.dart';
import '../../../util/const/app/app_strings.dart';
import '../../../util/const/ui/ui_constants.dart';

class PostMediaGallery extends StatelessWidget {
  const PostMediaGallery({
    required this.postId,
    required this.media,
    super.key,
  });

  final String postId;
  final List<PostMedia> media;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    var index = 0;
    var imageOffset = 0;

    while (index < media.length) {
      if (media[index].isVideo) {
        children.add(_VideoPreview(media: media[index]));
        index++;
        continue;
      }

      final photos = <PostMedia>[];
      while (index < media.length && !media[index].isVideo) {
        photos.add(media[index]);
        index++;
      }
      children.add(
        _PhotoCollection(
          postId: postId,
          media: photos,
          collectionOffset: imageOffset,
        ),
      );
      imageOffset += photos.length;
    }

    return Column(
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
    required this.postId,
    required this.media,
    required this.collectionOffset,
  });

  final String postId;
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
    final heroTag = '$postId-${photo.id}';

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
                    semanticLabel: label,
                  ),
                ),
                if (remainingCount > 0)
                  ColoredBox(
                    color: Colors.black54,
                    child: Center(
                      child: Text(
                        '+$remainingCount',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(color: Colors.white),
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
              postId: postId,
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
    required this.postId,
    required this.media,
    required this.initialIndex,
  });

  final String postId;
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
    final counter = AppStrings.imageViewerCounter
        .replaceAll('{current}', '${_currentIndex + 1}')
        .replaceAll('{total}', '${widget.media.length}');

    return Scaffold(
      backgroundColor: Colors.black,
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
                  tag: '${widget.postId}-${photo.id}',
                  child: _NetworkPhoto(
                    media: photo,
                    fit: BoxFit.contain,
                    semanticLabel: photo.altText,
                    loadingColor: Colors.white,
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
                        backgroundColor: Colors.black54,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.close),
                    ),
                    const Spacer(),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black54,
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
                              ?.copyWith(color: Colors.white),
                        ),
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
  }
}

class _VideoPreview extends StatelessWidget {
  const _VideoPreview({required this.media});

  final PostMedia media;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: AppStrings.playVideo,
      child: AspectRatio(
        aspectRatio: UIConstants.postMediaAspectRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(UIConstants.postMediaRadius),
          child: Material(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: InkWell(
              onTap: () => context.go(Routes.videos),
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
                  const Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
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

class _NetworkPhoto extends StatelessWidget {
  const _NetworkPhoto({
    required this.media,
    required this.fit,
    this.sourceUrl,
    this.semanticLabel,
    this.loadingColor,
  });

  final PostMedia media;
  final BoxFit fit;
  final String? sourceUrl;
  final String? semanticLabel;
  final Color? loadingColor;

  @override
  Widget build(BuildContext context) => Image.network(
    sourceUrl ?? media.sourceUrl,
    fit: fit,
    semanticLabel: semanticLabel,
    loadingBuilder: (context, child, progress) {
      if (progress == null) return child;
      return Center(
        child: CircularProgressIndicator(
          color: loadingColor ?? Theme.of(context).colorScheme.primary,
        ),
      );
    },
    errorBuilder: (context, error, stackTrace) => Tooltip(
      message: AppStrings.imageLoadFailed,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    ),
  );
}
