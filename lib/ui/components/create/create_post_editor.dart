import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../model/create/content_type.dart';
import '../../../model/create/post_draft.dart';
import '../../../provider/create/create_post_provider.dart';
import '../../../util/const/app/app_strings.dart';
import '../../../util/const/ui/ui_constants.dart';
import '../avatar.dart';

/// Editor de rascunho de publicação.
///
/// Adapta seus campos ao [ContentType] do rascunho:
/// - Texto/Story → campo de texto simples
/// - Artigo     → título + corpo
/// - Foto/Vídeo/Áudio → painel de mídia + legenda
/// - Enquete    → pergunta + opções dinâmicas
/// - Evento     → título + data + local
/// - Live       → título da transmissão
class CreatePostEditor extends StatelessWidget {
  const CreatePostEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CreatePostProvider>(
      builder: (context, provider, _) {
        final draft = provider.draft;

        return ListView(
          padding: EdgeInsets.only(
            left: UIConstants.createEditorHorizontalPadding,
            right: UIConstants.createEditorHorizontalPadding,
            top: UIConstants.createEditorVerticalPadding,
            bottom:
                UIConstants.createEditorVerticalPadding +
                MediaQuery.viewInsetsOf(context).bottom,
          ),
          children: [
            _AuthorRow(),
            const SizedBox(height: UIConstants.createEditorSectionSpacing),
            if (draft.hasTitle) ...[
              _TitleField(provider: provider, draft: draft),
              const SizedBox(height: UIConstants.createEditorSectionSpacing),
            ],
            _BodyField(provider: provider, draft: draft),
            if (draft.requiresMedia) ...[
              const SizedBox(height: UIConstants.createEditorSectionSpacing),
              _MediaPanel(provider: provider, draft: draft),
            ],
            if (draft.hasPollOptions) ...[
              const SizedBox(height: UIConstants.createEditorSectionSpacing),
              _PollOptionsPanel(provider: provider, draft: draft),
            ],
            if (draft.hasEventFields) ...[
              const SizedBox(height: UIConstants.createEditorSectionSpacing),
              _EventFieldsPanel(provider: provider, draft: draft),
            ],
            if (draft.type == ContentType.live) ...[
              const SizedBox(height: UIConstants.createEditorSectionSpacing),
              _LiveHintChip(),
            ],
            const SizedBox(height: UIConstants.createEditorSectionSpacing),
            _VisibilitySelector(provider: provider, draft: draft),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Linha do autor
// ---------------------------------------------------------------------------

class _AuthorRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Avatar(size: AvatarSize.small),
        const SizedBox(width: UIConstants.createEditorAvatarSpacing),
        Text(
          AppStrings.yourStory,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Campo de título
// ---------------------------------------------------------------------------

class _TitleField extends StatelessWidget {
  const _TitleField({required this.provider, required this.draft});

  final CreatePostProvider provider;
  final PostDraft draft;

  String get _hint => switch (draft.type) {
    ContentType.article => AppStrings.createEditorTitleHint,
    ContentType.event => AppStrings.createEditorTitleHint,
    ContentType.live => AppStrings.createEditorLiveTitleHint,
    _ => AppStrings.createEditorTitleHint,
  };

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: _hint,
        border: InputBorder.none,
        hintStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      style: Theme.of(context).textTheme.headlineSmall,
      textCapitalization: TextCapitalization.sentences,
      maxLines: null,
      onChanged: provider.setTitle,
    );
  }
}

// ---------------------------------------------------------------------------
// Campo de corpo / texto principal
// ---------------------------------------------------------------------------

class _BodyField extends StatelessWidget {
  const _BodyField({required this.provider, required this.draft});

  final CreatePostProvider provider;
  final PostDraft draft;

  String get _hint => switch (draft.type) {
    ContentType.article => AppStrings.createEditorArticleBodyHint,
    ContentType.photo ||
    ContentType.video ||
    ContentType.audio =>
      AppStrings.createEditorBodyHint,
    ContentType.poll => AppStrings.createEditorBodyHint,
    ContentType.event => AppStrings.createEditorBodyHint,
    _ => AppStrings.createEditorBodyHint,
  };

  int? get _maxLines => switch (draft.type) {
    ContentType.article => null,
    ContentType.photo || ContentType.video || ContentType.audio => 4,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: _hint,
        border: InputBorder.none,
      ),
      style: Theme.of(context).textTheme.bodyLarge,
      textCapitalization: TextCapitalization.sentences,
      maxLines: _maxLines ?? 999,
      minLines: 3,
      onChanged: provider.setBody,
    );
  }
}

// ---------------------------------------------------------------------------
// Painel de mídia (simulado)
// ---------------------------------------------------------------------------

class _MediaPanel extends StatelessWidget {
  const _MediaPanel({required this.provider, required this.draft});

  final CreatePostProvider provider;
  final PostDraft draft;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final count = draft.mediaCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (count > 0) ...[
          Wrap(
            spacing: UIConstants.createEditorSectionSpacing,
            runSpacing: UIConstants.createEditorSectionSpacing,
            children: [
              for (var i = 0; i < count; i++)
                _MediaPreviewChip(
                  index: i,
                  type: draft.type,
                  onRemove: provider.removeMedia,
                ),
            ],
          ),
          const SizedBox(height: UIConstants.createEditorSectionSpacing),
        ],
        OutlinedButton.icon(
          onPressed: provider.addMedia,
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: const Text(AppStrings.createEditorAddMedia),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                UIConstants.createEditorMediaAddRadius,
              ),
            ),
          ),
        ),
        const SizedBox(height: UIConstants.createEditorPollSpacing),
        Text(
          AppStrings.createMediaSimulatedHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _MediaPreviewChip extends StatelessWidget {
  const _MediaPreviewChip({
    required this.index,
    required this.type,
    required this.onRemove,
  });

  final int index;
  final ContentType type;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final icon = switch (type) {
      ContentType.video => Icons.videocam_rounded,
      ContentType.audio => Icons.mic_rounded,
      _ => Icons.photo_rounded,
    };

    return Stack(
      children: [
        Container(
          width: UIConstants.createEditorMediaPreviewSize,
          height: UIConstants.createEditorMediaPreviewSize,
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(
              UIConstants.createEditorMediaAddRadius,
            ),
          ),
          child: Icon(icon, color: colors.onSurfaceVariant),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: colors.error,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 12,
                color: colors.onError,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Painel de enquete
// ---------------------------------------------------------------------------

class _PollOptionsPanel extends StatelessWidget {
  const _PollOptionsPanel({required this.provider, required this.draft});

  final CreatePostProvider provider;
  final PostDraft draft;

  @override
  Widget build(BuildContext context) {
    final options = draft.pollOptions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < options.length; i++) ...[
          _PollOptionField(
            index: i,
            provider: provider,
            canRemove: options.length > 2,
          ),
          const SizedBox(height: UIConstants.createEditorPollSpacing),
        ],
        TextButton.icon(
          onPressed: provider.addPollOption,
          icon: const Icon(Icons.add),
          label: const Text(AppStrings.createEditorAddPollOption),
        ),
      ],
    );
  }
}

class _PollOptionField extends StatelessWidget {
  const _PollOptionField({
    required this.index,
    required this.provider,
    required this.canRemove,
  });

  final int index;
  final CreatePostProvider provider;
  final bool canRemove;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hint = AppStrings.createEditorPollOptionHint.replaceAll(
      '{number}',
      '${index + 1}',
    );

    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: hint,
              isDense: true,
              filled: true,
              fillColor: colors.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(
                  UIConstants.createEditorPollOptionRadius,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: UIConstants.spaceMd,
                vertical: UIConstants.spaceSm,
              ),
            ),
            onChanged: (v) => provider.setPollOptionText(index, v),
          ),
        ),
        if (canRemove) ...[
          const SizedBox(width: UIConstants.spaceXs),
          IconButton(
            onPressed: () => provider.removePollOption(index),
            icon: const Icon(Icons.close),
            iconSize: UIConstants.commentLikeIconSize,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Campos de evento
// ---------------------------------------------------------------------------

class _EventFieldsPanel extends StatelessWidget {
  const _EventFieldsPanel({required this.provider, required this.draft});

  final CreatePostProvider provider;
  final PostDraft draft;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final fieldDecoration = InputDecoration(
      isDense: true,
      filled: true,
      fillColor: colors.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(UIConstants.createEditorFieldRadius),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: UIConstants.spaceMd,
        vertical: UIConstants.spaceSm,
      ),
    );

    return Column(
      children: [
        TextField(
          decoration: fieldDecoration.copyWith(
            hintText: AppStrings.createEditorEventDateHint,
            prefixIcon: const Icon(Icons.calendar_today_outlined),
          ),
          readOnly: true,
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
            );
            if (picked != null) {
              provider.setEventDate(
                '${picked.day.toString().padLeft(2, '0')}/'
                '${picked.month.toString().padLeft(2, '0')}/'
                '${picked.year}',
              );
            }
          },
          controller: TextEditingController(text: draft.eventDate),
        ),
        const SizedBox(height: UIConstants.createEditorSectionSpacing),
        TextField(
          decoration: fieldDecoration.copyWith(
            hintText: AppStrings.createEditorEventLocationHint,
            prefixIcon: const Icon(Icons.place_outlined),
          ),
          onChanged: provider.setEventLocation,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Chip de aviso para Live
// ---------------------------------------------------------------------------

class _LiveHintChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.spaceMd,
        vertical: UIConstants.spaceSm,
      ),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(UIConstants.createEditorFieldRadius),
      ),
      child: Row(
        children: [
          Icon(Icons.live_tv_rounded, color: colors.onErrorContainer, size: 20),
          const SizedBox(width: UIConstants.spaceSm),
          Expanded(
            child: Text(
              'A transmissão ao vivo começará assim que você publicar.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Seletor de visibilidade
// ---------------------------------------------------------------------------

class _VisibilitySelector extends StatelessWidget {
  const _VisibilitySelector({required this.provider, required this.draft});

  final CreatePostProvider provider;
  final PostDraft draft;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isPublic = draft.visibility == DraftVisibility.public;

    return Row(
      children: [
        Icon(
          Icons.visibility_outlined,
          size: 18,
          color: colors.onSurfaceVariant,
        ),
        const SizedBox(width: UIConstants.spaceXs),
        Text(
          AppStrings.createEditorVisibilityLabel,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: UIConstants.spaceSm),
        ChoiceChip(
          label: const Text(AppStrings.createEditorVisibilityPublic),
          selected: isPublic,
          onSelected: (_) => provider.setVisibility(DraftVisibility.public),
        ),
        const SizedBox(width: UIConstants.spaceXs),
        ChoiceChip(
          label: const Text(AppStrings.createEditorVisibilityFriends),
          selected: !isPublic,
          onSelected: (_) =>
              provider.setVisibility(DraftVisibility.friendsOnly),
        ),
      ],
    );
  }
}
