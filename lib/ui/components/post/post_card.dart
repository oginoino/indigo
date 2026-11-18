import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../model/post/post.dart';
import '../../../model/post/post_media.dart';
import '../../../route/routes.dart';
import '../../../util/const/app/app_strings.dart';
import '../../../util/const/ui/ui_constants.dart';

class PostCard extends StatelessWidget {
  const PostCard({required this.post, super.key});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = post.content.plainText;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: UIConstants.defaultPadding,
        vertical: UIConstants.postCardSpacing / 2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.postCardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.title case final title?) ...[
              Text(title, style: theme.textTheme.titleMedium),
              const SizedBox(height: UIConstants.postCardSpacing),
            ],
            if (content.isNotEmpty)
              Text(content, style: theme.textTheme.bodyLarge),
            for (final media in post.media)
              Padding(
                padding: const EdgeInsets.only(
                  top: UIConstants.postCardSpacing,
                ),
                child: _PostMediaPreview(media: media),
              ),
            const SizedBox(height: UIConstants.postCardSpacing),
            Text(
              '${post.engagement.reactionCount}'
              '${AppStrings.postEngagementSeparator}'
              '${post.engagement.commentCount}'
              '${AppStrings.postEngagementSeparator}'
              '${post.engagement.shareCount}',
              style: theme.textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _PostMediaPreview extends StatelessWidget {
  const _PostMediaPreview({required this.media});

  final PostMedia media;

  @override
  Widget build(BuildContext context) {
    final imageUrl = media.isVideo ? media.thumbnailUrl : media.sourceUrl;
    final preview = AspectRatio(
      aspectRatio: UIConstants.postMediaAspectRatio,
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: imageUrl == null
            ? const Center(child: Icon(Icons.play_circle_outline))
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Center(child: Icon(Icons.broken_image_outlined)),
              ),
      ),
    );

    if (!media.isVideo) return preview;

    return InkWell(
      onTap: () => context.go(Routes.videos),
      child: Stack(
        alignment: Alignment.center,
        children: [
          preview,
          const Icon(
            Icons.play_circle_fill,
            size: UIConstants.videoActionIconSize * 2,
          ),
        ],
      ),
    );
  }
}
