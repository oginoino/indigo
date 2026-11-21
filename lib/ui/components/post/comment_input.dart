import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../model/party/user_profile.dart';
import '../../../provider/post/comments_provider.dart';
import '../../../util/const/app/app_strings.dart';
import '../../../util/const/ui/ui_constants.dart';
import '../avatar.dart';

/// Campo de entrada de comentário.
///
/// Exibe:
/// - Avatar do usuário corrente (placeholder quando não disponível).
/// - [TextField] com dica e borda arredondada.
/// - [IconButton] para enviar o comentário.
/// - Chip de "Respondendo a @username" quando há um comentário sendo
///   respondido, com botão para cancelar.
///
/// [currentUser] pode ser null quando o perfil ainda não foi carregado.
class CommentInput extends StatefulWidget {
  const CommentInput({required this.currentUser, super.key});

  final UserProfile? currentUser;

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _handleSend() {
    if (!_hasText) return;
    // TODO(comments): integrar envio real via serviço.
    _controller.clear();
    context.read<CommentsProvider>().setReplyingTo(null);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTextChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final replyingTo = context.select<CommentsProvider, String?>(
      (p) => p.replyingTo?.let((c) {
        final author = p.authorFor(c);
        return author?.username;
      }),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (replyingTo != null)
          _ReplyingToChip(
            username: replyingTo,
            onCancel: () =>
                context.read<CommentsProvider>().setReplyingTo(null),
          ),
        _InputRow(
          currentUser: widget.currentUser,
          controller: _controller,
          hasText: _hasText,
          onSend: _handleSend,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _ReplyingToChip extends StatelessWidget {
  const _ReplyingToChip({
    required this.username,
    required this.onCancel,
  });

  final String username;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = AppStrings.commentReplyingTo.replaceAll(
      '{username}',
      username,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: UIConstants.commentContentSpacing),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            iconSize: UIConstants.commentLikeIconSize,
            visualDensity: VisualDensity.compact,
            onPressed: onCancel,
            tooltip: AppStrings.commentDeleteTooltip,
          ),
        ],
      ),
    );
  }
}

class _InputRow extends StatelessWidget {
  const _InputRow({
    required this.currentUser,
    required this.controller,
    required this.hasText,
    required this.onSend,
  });

  final UserProfile? currentUser;
  final TextEditingController controller;
  final bool hasText;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarUrl = currentUser?.avatarUrl;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Avatar(
          diameter: UIConstants.commentInputAvatarSize,
          imageProvider: avatarUrl == null || avatarUrl.isEmpty
              ? null
              : NetworkImage(avatarUrl),
          useSavedImage: true,
        ),
        const SizedBox(width: UIConstants.commentItemSpacing),
        Expanded(
          child: SizedBox(
            height: UIConstants.commentInputHeight,
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: AppStrings.commentInputHint,
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.commentInputHorizontalPadding,
                  vertical: UIConstants.commentContentSpacing,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    UIConstants.commentInputBorderRadius,
                  ),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: UIConstants.engagementColorDuration,
          child: hasText
              ? IconButton(
                  key: const ValueKey('send'),
                  icon: const Icon(Icons.send_rounded),
                  color: theme.colorScheme.primary,
                  tooltip: AppStrings.commentSend,
                  onPressed: onSend,
                )
              : const SizedBox(key: ValueKey('empty'), width: UIConstants.commentItemSpacing),
        ),
      ],
    );
  }
}

// ignore: unused_element
extension _LetExtension<T> on T {
  R let<R>(R Function(T) block) => block(this);
}
