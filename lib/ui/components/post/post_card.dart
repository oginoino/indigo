import 'package:material_ui/material_ui.dart';

import '../../../model/post/post.dart';
import '../../../util/const/app/app_strings.dart';
import '../../../util/const/ui/ui_constants.dart';
import 'post_media_gallery.dart';

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
            PostMediaGallery(postId: post.id, media: post.media),
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
