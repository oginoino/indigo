import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../model/party/user_profile.dart';
import '../../../model/post/post.dart';
import '../../../provider/post/posts_provider.dart';
import '../../../util/const/ui/ui_constants.dart';
import 'comments_bottom_sheet.dart';
import 'post_author_header.dart';
import 'post_engagement_bar.dart';
import 'post_engagement_proxy.dart';
import 'post_long_text_preview.dart';
import 'post_media_gallery.dart';

/// Card de post no feed.
///
/// Conecta automaticamente as ações de engajamento (curtir, salvar, repostar,
/// comentar) ao [PostsProvider] e [CommentsProvider] da árvore.
class PostCard extends StatelessWidget {
  const PostCard({required this.post, required this.author, super.key});

  final Post post;
  final UserProfile? author;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final postsProvider = context.read<PostsProvider>();
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
              PostAuthorHeader(
                author: author,
                publishedAt: post.createdAt,
                location: post.location,
              ),
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
              // Selector reconstrói quando qualquer flag de engajamento muda.
              Selector<PostsProvider, (bool, bool, bool)>(
                selector: (_, p) {
                  final v = p.engagementFor(post).viewer;
                  return (v.isReacted, v.isSaved, v.isShared);
                },
                builder: (context, _, _) {
                  final engagement = postsProvider.engagementFor(post);
                  final effectivePost = PostEngagementProxy(post, engagement);
                  return PostEngagementBar(
                    post: effectivePost,
                    onComment: () => CommentsBottomSheet.show(
                      context,
                      postId: post.id,
                      currentUser: author,
                    ),
                    onLike: () => postsProvider.toggleLike(post),
                    onRepost: () => postsProvider.toggleRepost(post),
                    onSave: () => postsProvider.toggleSave(post),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
