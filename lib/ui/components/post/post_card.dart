import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../model/party/user_profile.dart';
import '../../../model/post/post.dart';
import '../../../model/post/post_content.dart';
import '../../../model/post/post_engagement_summary.dart';
import '../../../model/post/post_location.dart';
import '../../../model/post/post_media.dart';
import '../../../model/post/post_relationship.dart';
import '../../../model/post/post_sticker.dart';
import '../../../model/post/post_tag.dart';
import '../../../provider/post/posts_provider.dart';
import '../../../util/const/ui/ui_constants.dart';
import 'comments_bottom_sheet.dart';
import 'post_author_header.dart';
import 'post_engagement_bar.dart';
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
              // Selector reconstrói apenas quando o engagement deste post muda.
              Selector<PostsProvider, bool>(
                selector: (_, p) => p.engagementFor(post).viewer.isReacted,
                builder: (context, _, _) {
                  final engagement = postsProvider.engagementFor(post);
                  // Recria o Post com o engagement otimista para o bar.
                  final effectivePost = _PostWithEngagement(post, engagement);
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

/// Proxy de [Post] que substitui apenas o [engagement] por um override
/// otimista sem copiar todo o objeto.
class _PostWithEngagement implements Post {
  _PostWithEngagement(this._base, this._engagement);

  final Post _base;
  final PostEngagementSummary _engagement;

  @override
  PostEngagementSummary get engagement => _engagement;

  // ---- Delegação de todos os outros membros ----------------------------------
  @override
  String get id => _base.id;
  @override
  String get authorPartyRoleId => _base.authorPartyRoleId;
  @override
  PostContent get content => _base.content;
  @override
  String? get title => _base.title;
  @override
  String? get themeId => _base.themeId;
  @override
  PostLocation? get location => _base.location;
  @override
  List<PostMedia> get media => _base.media;
  @override
  List<PostSticker> get stickers => _base.stickers;
  @override
  List<PostTag> get tags => _base.tags;
  @override
  List<String> get feeds => _base.feeds;
  @override
  PostRelationship? get relationship => _base.relationship;
  @override
  PostVisibility get visibility => _base.visibility;
  @override
  PostStatus get status => _base.status;
  @override
  DateTime get createdAt => _base.createdAt;
  @override
  DateTime? get updatedAt => _base.updatedAt;
  @override
  DateTime? get expiresAt => _base.expiresAt;
  @override
  bool get isEphemeral => _base.isEphemeral;
  @override
  bool get hasTitle => _base.hasTitle;
  @override
  bool get hasLocation => _base.hasLocation;
  @override
  bool get hasStickers => _base.hasStickers;
  @override
  bool get hasVideo => _base.hasVideo;
  @override
  bool isPublishedAt(DateTime instant) => _base.isPublishedAt(instant);
}
