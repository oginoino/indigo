import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../model/post/post_comment.dart';
import '../../../provider/post/comments_provider.dart';
import '../../../util/const/app/app_strings.dart';
import '../../../util/const/ui/ui_constants.dart';
import 'comment_tile.dart';

/// Exibe um comentário raiz seguido de suas respostas (lazy — expandidas
/// apenas quando o usuário solicita).
///
/// Lê [CommentsProvider] via [context] para:
/// - saber se as respostas estão expandidas ([areRepliesExpanded]);
/// - acionar [toggleReplies] e [setReplyingTo].
class CommentReplyGroup extends StatelessWidget {
  const CommentReplyGroup({required this.comment, super.key});

  final PostComment comment;

  @override
  Widget build(BuildContext context) {
    // Lê apenas os dados relevantes para este grupo de comentário.
    final provider = context.read<CommentsProvider>();
    final author = provider.authorFor(comment);
    final replies = provider.repliesFor(comment.id);
    final replyCount = comment.engagement.replyCount;
    final hasReplies = replyCount > 0 || replies.isNotEmpty;

    return Selector<CommentsProvider, bool>(
      selector: (_, p) => p.areRepliesExpanded(comment.id),
      builder: (context, expanded, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommentTile(
              comment: comment,
              author: author,
              onLike: () {},
              onReply: () => context
                  .read<CommentsProvider>()
                  .setReplyingTo(comment.id),
            ),
            if (hasReplies)
              _RepliesToggle(
                commentId: comment.id,
                replyCount: replyCount,
                isExpanded: expanded,
              ),
            if (expanded)
              _ReplyList(commentId: comment.id, replies: replies),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _RepliesToggle extends StatelessWidget {
  const _RepliesToggle({
    required this.commentId,
    required this.replyCount,
    required this.isExpanded,
  });

  final String commentId;
  final int replyCount;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = isExpanded
        ? AppStrings.commentHideReplies
        : AppStrings.commentLoadReplies.replaceAll(
            '{count}',
            '$replyCount',
          );

    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: UIConstants.commentIndent +
            UIConstants.commentAvatarSize +
            UIConstants.commentItemSpacing,
      ),
      child: TextButton.icon(
        onPressed: () =>
            context.read<CommentsProvider>().toggleReplies(commentId),
        icon: Icon(
          isExpanded
              ? Icons.keyboard_arrow_up_rounded
              : Icons.keyboard_arrow_down_rounded,
          size: UIConstants.commentLikeIconSize,
        ),
        label: Text(label),
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
      ),
    );
  }
}

class _ReplyList extends StatelessWidget {
  const _ReplyList({required this.commentId, required this.replies});

  final String commentId;
  final List<PostComment> replies;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CommentsProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final reply in replies)
          CommentTile(
            key: ValueKey(reply.id),
            comment: reply,
            author: provider.authorFor(reply),
            isReply: true,
            onLike: () {},
            onReply: () =>
                context.read<CommentsProvider>().setReplyingTo(commentId),
          ),
      ],
    );
  }
}
