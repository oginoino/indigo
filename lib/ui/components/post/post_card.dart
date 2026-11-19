import 'package:material_ui/material_ui.dart';

import '../../../model/party/user_profile.dart';
import '../../../model/post/post.dart';
import '../../../util/const/ui/ui_constants.dart';
import 'post_author_header.dart';
import 'post_engagement_bar.dart';
import 'post_media_gallery.dart';
import 'post_long_text_preview.dart';

class PostCard extends StatelessWidget {
  const PostCard({required this.post, required this.author, super.key});

  final Post post;
  final UserProfile? author;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = post.title?.trim();
    final content = post.content.plainText.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.postCardHorizontalInset,
        vertical: UIConstants.postCardOuterSpacing,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(UIConstants.postCardContentPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PostAuthorHeader(author: author, publishedAt: post.createdAt),
              const SizedBox(height: UIConstants.postCardSpacing),
              if (title != null && title.isNotEmpty) ...[
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: UIConstants.postCardSpacing),
              ],
              if (content.isNotEmpty)
                PostLongTextPreview(post: post, author: author, text: content),
              if (post.media.isNotEmpty)
                PostMediaGallery(post: post, author: author),
              const SizedBox(height: UIConstants.postCardSpacing),
              PostEngagementBar(post: post),
            ],
          ),
        ),
      ),
    );
  }
}
