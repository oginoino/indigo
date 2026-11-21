import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../model/create/content_type.dart';
import '../../../model/create/post_draft.dart';
import '../../../provider/create/create_post_provider.dart';
import '../../../util/const/app/app_strings.dart';
import '../../../util/const/ui/ui_constants.dart';
import '../avatar.dart';
import 'media_picker_sheet.dart';
import 'media_preview_strip.dart';

/// Editor de rascunho de publicação.
///
/// Adapta seus campos ao [ContentType] do rascunho:
/// - Texto/Story → campo de texto simples
/// - Artigo     → título + corpo
/// - Foto/Vídeo/Áudio → strip de mídia + legenda
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
              _MediaSection(provider: provider, draft: draft),
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
      decoration: InputDecoration(hintText: _hint, border: InputBorder.none),
      style: Theme.of(context).textTheme.bodyLarge,
      textCapitalization: TextCapitalization.sentences,
      maxLines: _maxLines ?? 999,
      minLines: 3,
      onChanged: provider.setBody,
    );
  }
}

// ---------------------------------------------------------------------------
// Seção de mídia (strip real + botão adicionar)
// ---------------------------------------------------------------------------

class _MediaSection extends StatelessWidget {
  const _MediaSection({required this.provider, required this.draft});

  final CreatePostProvider provider;
  final PostDraft draft;

  Future<void> _openPicker(BuildContext context) => showMediaPickerSheet(
    context,
    allowVideo: draft.type == ContentType.video,
  );

  @override
  Widget build(BuildContext context) {
    final hasMedia = provider.mediaItems.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasMedia) ...[
          MediaPreviewStrip(
            items: provider.mediaItems,
            onRemove: provider.removeMediaAt,
            onAdd: () => _openPicker(context),
          ),
          const SizedBox(height: UIConstants.createEditorSectionSpacing),
        ],
        OutlinedButton.icon(
          onPressed: () => _openPicker(context),
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
              AppStrings.createLiveHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.onErrorContainer,
              ),
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
          onSelected: (_) => provider.setVisibility(DraftVisibility.friendsOnly),
        ),
      ],
    );
  }
}
