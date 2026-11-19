import 'package:material_ui/material_ui.dart';

import '../../../model/party/user_profile.dart';
import '../../../model/post/post.dart';
import '../../../util/const/ui/ui_constants.dart';
import 'post_author_header.dart';
import 'post_engagement_bar.dart';
import 'post_media_gallery.dart';

class PostCard extends StatelessWidget {
  const PostCard({required this.post, required this.author, super.key});

  final Post post;
  final UserProfile? author;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = post.content.plainText;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.postCardHorizontalInset,
        vertical: UIConstants.postCardOuterSpacing,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(UIConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PostAuthorHeader(author: author, publishedAt: post.createdAt),
              const SizedBox(height: UIConstants.postCardSpacing),
              if (post.title case final title?) ...[
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: UIConstants.postCardSpacing),
              ],
              if (content.isNotEmpty)
                Text(content, style: theme.textTheme.bodyLarge),
              PostMediaGallery(post: post, author: author),
              const SizedBox(height: UIConstants.postCardSpacing),
              const Divider(),
              PostEngagementBar(post: post),
            ],
          ),
        ),
      ),
    );
  }
}
