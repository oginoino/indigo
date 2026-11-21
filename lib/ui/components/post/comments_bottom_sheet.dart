import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../model/party/user_profile.dart';
import '../../../provider/post/comments_provider.dart';
import '../../../util/const/app/app_strings.dart';
import '../../../util/const/ui/ui_constants.dart';
import 'comment_input.dart';
import 'comment_reply_group.dart';

/// Exibe a seção de comentários de um post em um modal bottom sheet
/// que pode ser arrastado de [UIConstants.commentSheetMinChildSize] até
/// [UIConstants.commentSheetMaxChildSize].
///
/// Chame [CommentsBottomSheet.show] a partir de qualquer [BuildContext] que
/// tenha acesso ao [CommentsProvider] na árvore.
class CommentsBottomSheet extends StatefulWidget {
  const CommentsBottomSheet({
    required this.postId,
    required this.currentUser,
    super.key,
  });

  final String postId;
  final UserProfile? currentUser;

  /// Abre o bottom sheet de comentários do [postId].
  static Future<void> show(
    BuildContext context, {
    required String postId,
    required UserProfile? currentUser,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsBottomSheet(
        postId: postId,
        currentUser: currentUser,
      ),
    );
  }

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  @override
  void initState() {
    super.initState();
    // Carrega os comentários logo ao abrir o sheet.
    // Usa addPostFrameCallback para garantir que o BuildContext já tem o
    // CommentsProvider disponível via Navigator overlay.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CommentsProvider>().loadForPost(widget.postId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return DraggableScrollableSheet(
      initialChildSize: UIConstants.commentSheetInitialChildSize,
      minChildSize: UIConstants.commentSheetMinChildSize,
      maxChildSize: UIConstants.commentSheetMaxChildSize,
      expand: false,
      snap: true,
      snapSizes: const [
        UIConstants.commentSheetInitialChildSize,
        UIConstants.commentSheetMaxChildSize,
      ],
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(UIConstants.radiusLg),
            ),
          ),
          child: Column(
            children: [
              _DragHandle(),
              _SheetHeader(postId: widget.postId),
              const Divider(height: 1),
              Expanded(
                child: _CommentScrollBody(
                  postId: widget.postId,
                  scrollController: scrollController,
                ),
              ),
              _StickyInput(
                currentUser: widget.currentUser,
                bottomInset: bottomInset,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: UIConstants.commentSpacing,
      ),
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(
              UIConstants.commentSheetDragHandleRadius,
            ),
          ),
          child: const SizedBox(
            width: UIConstants.commentSheetDragHandleWidth,
            height: UIConstants.commentSheetDragHandleHeight,
          ),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = context.select<CommentsProvider, int>(
      (p) => p.topLevelFor(postId).length,
    );
    final countLabel = count > 0 ? ' ($count)' : '';

    return SizedBox(
      height: UIConstants.commentSheetHeaderHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.commentSheetHorizontalPadding,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${AppStrings.commentsTitle}$countLabel',
                style: theme.textTheme.titleMedium,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded),
              tooltip: AppStrings.closeComments,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentScrollBody extends StatelessWidget {
  const _CommentScrollBody({
    required this.postId,
    required this.scrollController,
  });

  final String postId;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Selector<CommentsProvider, CommentsLoadStatus>(
      selector: (_, p) => p.statusFor(postId),
      builder: (context, status, _) {
        return switch (status) {
          CommentsLoadStatus.initial ||
          CommentsLoadStatus.loading => const Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          CommentsLoadStatus.error => Center(
              child: Text(
                AppStrings.postsLoadFailed,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          CommentsLoadStatus.loaded => _CommentListScrollable(
              postId: postId,
              scrollController: scrollController,
            ),
        };
      },
    );
  }
}

class _CommentListScrollable extends StatelessWidget {
  const _CommentListScrollable({
    required this.postId,
    required this.scrollController,
  });

  final String postId;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final comments =
        context.select<CommentsProvider, int>((p) => p.topLevelFor(postId).length);

    if (comments == 0) {
      return ListView(
        controller: scrollController,
        children: [
          Padding(
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
          ),
        ],
      );
    }

    final topLevel =
        context.read<CommentsProvider>().topLevelFor(postId);

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.commentSheetHorizontalPadding,
        vertical: UIConstants.commentItemSpacing,
      ),
      itemCount: topLevel.length,
      itemBuilder: (context, index) => CommentReplyGroup(
        key: ValueKey(topLevel[index].id),
        comment: topLevel[index],
      ),
    );
  }
}

class _StickyInput extends StatelessWidget {
  const _StickyInput({
    required this.currentUser,
    required this.bottomInset,
  });

  final UserProfile? currentUser;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          UIConstants.commentSheetHorizontalPadding,
          UIConstants.commentSheetInputPadding,
          UIConstants.commentSheetHorizontalPadding,
          UIConstants.commentSheetInputPadding + bottomInset,
        ),
        child: CommentInput(currentUser: currentUser),
      ),
    );
  }
}
