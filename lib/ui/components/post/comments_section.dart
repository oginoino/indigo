import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../model/party/user_profile.dart';
import '../../../provider/post/comments_provider.dart';
import '../../../util/const/app/app_strings.dart';
import '../../../util/const/ui/ui_constants.dart';
import 'comment_input.dart';
import 'comment_reply_group.dart';

/// Seção completa de comentários de um post.
///
/// Responsabilidades:
/// 1. Disparar [CommentsProvider.loadForPost] ao ser montada.
/// 2. Exibir estado de carregamento, erro, lista vazia ou lista de comentários.
/// 3. Exibir o campo de entrada ([CommentInput]) no rodapé.
///
/// Integra-se ao [CommentsProvider] via [Provider] — não precisa receber dados
/// pré-carregados pelo pai.
class CommentsSection extends StatefulWidget {
  const CommentsSection({
    required this.postId,
    required this.currentUser,
    super.key,
  });

  final String postId;

  /// Perfil do usuário corrente, usado pelo [CommentInput].
  final UserProfile? currentUser;

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Idempotente: chamadas redundantes são ignoradas no provider.
    context.read<CommentsProvider>().loadForPost(widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Selector<CommentsProvider, (CommentsLoadStatus, int)>(
      selector: (_, p) => (
        p.statusFor(widget.postId),
        p.topLevelFor(widget.postId).length,
      ),
      builder: (context, data, _) {
        final (status, count) = data;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(count: count),
            const SizedBox(height: UIConstants.commentSpacing),
            _buildBody(context, theme, status),
            const SizedBox(height: UIConstants.commentSpacing),
            CommentInput(currentUser: widget.currentUser),
          ],
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    ThemeData theme,
    CommentsLoadStatus status,
  ) {
    return switch (status) {
      CommentsLoadStatus.initial ||
      CommentsLoadStatus.loading => const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: UIConstants.postArticleSectionSpacing,
            ),
            child: CircularProgressIndicator.adaptive(),
          ),
        ),
      CommentsLoadStatus.error => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: UIConstants.postArticleSectionSpacing,
            ),
            child: Text(
              AppStrings.postsLoadFailed,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ),
      CommentsLoadStatus.loaded => _CommentList(postId: widget.postId),
    };
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final countLabel = count > 0 ? ' ($count)' : '';

    return Text(
      '${AppStrings.comments}$countLabel',
      style: theme.textTheme.titleMedium,
    );
  }
}

class _CommentList extends StatelessWidget {
  const _CommentList({required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final comments =
        context.read<CommentsProvider>().topLevelFor(postId);

    if (comments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: UIConstants.postArticleSectionSpacing,
        ),
        child: Center(
          child: Text(
            AppStrings.commentNoComments,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final comment in comments)
          CommentReplyGroup(key: ValueKey(comment.id), comment: comment),
      ],
    );
  }
}
