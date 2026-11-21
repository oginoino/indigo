import 'package:material_ui/material_ui.dart';

import '../../../model/party/user_profile.dart';
import '../../../model/post/post_comment.dart';
import '../../../util/const/app/app_strings.dart';
import '../../../util/const/ui/ui_constants.dart';
import '../../../util/formatter/post_time_formatter.dart';
import '../avatar.dart';
import 'animated_engagement_icon.dart';
import 'post_content_text.dart';

/// Tile de um único comentário ou resposta.
///
/// Exibe avatar do autor, nome, timestamp, corpo do comentário e ações
/// (curtir / responder). Quando [isReply] é true, adiciona um recuo à esquerda
/// equivalente a [UIConstants.commentIndent].
class CommentTile extends StatelessWidget {
  const CommentTile({
    required this.comment,
    required this.author,
    this.isReply = false,
    this.onLike,
    this.onReply,
    super.key,
  });

  final PostComment comment;
  final UserProfile? author;
  final bool isReply;
  final VoidCallback? onLike;
  final VoidCallback? onReply;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLiked = comment.engagement.viewerReaction != null;
    // Reutiliza o token de cor de curtidas definido globalmente.
    final likeColor =
        isLiked ? UIConstants.likedColor : theme.colorScheme.onSurfaceVariant;
    final likeLabel =
        isLiked ? AppStrings.commentUnlike : AppStrings.commentLike;

    Widget tile = Padding(
      padding: const EdgeInsets.symmetric(
        vertical: UIConstants.commentItemSpacing,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CommentAvatar(author: author),
          const SizedBox(width: UIConstants.commentItemSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AuthorRow(author: author, publishedAt: comment.createdAt),
                const SizedBox(height: UIConstants.commentContentSpacing),
                PostContentText(
                  content: comment.content,
                  style: theme.textTheme.bodyMedium,
                  maxLines: UIConstants.commentMaxLines,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: UIConstants.commentContentSpacing),
                _ActionRow(
                  isLiked: isLiked,
                  likeColor: likeColor,
                  likeLabel: likeLabel,
                  likeCount: comment.engagement.reactionCount,
                  onLike: onLike,
                  onReply: onReply,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (isReply) {
      tile = Padding(
        padding: const EdgeInsetsDirectional.only(
          start: UIConstants.commentIndent,
        ),
        child: tile,
      );
    }

    return tile;
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _CommentAvatar extends StatelessWidget {
  const _CommentAvatar({required this.author});

  final UserProfile? author;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = author?.avatarUrl;
    return Avatar(
      diameter: UIConstants.commentAvatarSize,
      imageProvider: avatarUrl == null || avatarUrl.isEmpty
          ? null
          : NetworkImage(avatarUrl),
      useSavedImage: false,
    );
  }
}

class _AuthorRow extends StatelessWidget {
  const _AuthorRow({required this.author, required this.publishedAt});

  final UserProfile? author;
  final DateTime publishedAt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final absoluteTime = PostTimeFormatter.formatAbsolute(publishedAt);
    final relativeTime = PostTimeFormatter.formatRelative(publishedAt);
    final nameStyle = theme.textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w600,
    );
    final detailStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Row(
      children: [
        Flexible(
          child: Text(
            author?.displayName ?? AppStrings.unknownPostAuthor,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: nameStyle,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.commentContentSpacing,
          ),
          child: Text(
            AppStrings.postEngagementSeparator,
            style: detailStyle,
          ),
        ),
        Flexible(
          child: Semantics(
            label: absoluteTime,
            child: Tooltip(
              message: absoluteTime,
              child: Text(
                relativeTime,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: detailStyle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.isLiked,
    required this.likeColor,
    required this.likeLabel,
    required this.likeCount,
    required this.onLike,
    required this.onReply,
  });

  final bool isLiked;
  final Color likeColor;
  final String likeLabel;
  final int likeCount;
  final VoidCallback? onLike;
  final VoidCallback? onReply;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final countStyle = theme.textTheme.labelSmall?.copyWith(
      color: likeColor,
      fontWeight: FontWeight.w600,
    );

    return Row(
      children: [
        Semantics(
          label: '$likeLabel: $likeCount',
          container: true,
          button: true,
          enabled: onLike != null,
          onTap: onLike,
          excludeSemantics: true,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedEngagementIcon(
                icon: isLiked ? Icons.favorite : Icons.favorite_border,
                color: likeColor,
                iconSize: UIConstants.commentLikeIconSize,
                buttonSize: UIConstants.commentLikeButtonSize,
                tooltip: likeLabel,
                effect: EngagementEffect.pop,
                isActive: isLiked,
                playOnTap: true,
                onPressed: onLike,
              ),
              if (likeCount > 0) ...[
                const SizedBox(width: UIConstants.commentContentSpacing),
                Text('$likeCount', style: countStyle),
              ],
            ],
          ),
        ),
        if (onReply != null) ...[
          const SizedBox(width: UIConstants.commentSpacing),
          TextButton(
            onPressed: onReply,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.commentItemSpacing,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text(AppStrings.commentReply),
          ),
        ],
      ],
    );
  }
}
