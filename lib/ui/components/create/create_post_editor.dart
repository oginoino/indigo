import 'dart:io';

import 'package:image_picker/image_picker.dart';
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

/// Editor contextual de rascunho — layout e campos adaptados por [ContentType].
///
/// Cada tipo tem sua própria UX inspirada no melhor app do segmento:
/// - Post    → Twitter/X: composer com thread
/// - Foto    → Instagram: carrossel + legenda + local
/// - Vídeo   → TikTok: thumb + título + hashtags
/// - Áudio   → Podcast: player preview + título obrigatório
/// - Story   → Snapchat/Instagram: preview 9:16 + texto sobreposto
/// - Artigo  → Medium: capa + título grande + corpo
/// - Enquete → Twitter: pergunta + opções + duração
/// - Evento  → Google Calendar: banner + data + local + formato
/// - Live    → YouTube: thumb + título + categoria + schedule
class CreatePostEditor extends StatelessWidget {
  const CreatePostEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CreatePostProvider>(
      builder: (context, provider, _) {
        final draft = provider.draft;
        return switch (draft.type) {
          ContentType.post => _PostEditor(provider: provider, draft: draft),
          ContentType.photo => _PhotoEditor(provider: provider, draft: draft),
          ContentType.video => _VideoEditor(provider: provider, draft: draft),
          ContentType.audio => _AudioEditor(provider: provider, draft: draft),
          ContentType.story => _StoryEditor(provider: provider, draft: draft),
          ContentType.article =>
            _ArticleEditor(provider: provider, draft: draft),
          ContentType.poll => _PollEditor(provider: provider, draft: draft),
          ContentType.event => _EventEditor(provider: provider, draft: draft),
          ContentType.live => _LiveEditor(provider: provider, draft: draft),
        };
      },
    );
  }
}

// ===========================================================================
// HELPERS COMPARTILHADOS
// ===========================================================================

/// Padding padrão do editor para tipos de scroll vertical.
EdgeInsets _editorPadding(BuildContext context) => EdgeInsets.only(
      left: UIConstants.createEditorHorizontalPadding,
      right: UIConstants.createEditorHorizontalPadding,
      top: UIConstants.createEditorVerticalPadding,
      bottom: UIConstants.createEditorVerticalPadding +
          MediaQuery.viewInsetsOf(context).bottom,
    );

/// Linha de autor (avatar + nome) comum a vários tipos.
class _AuthorRow extends StatelessWidget {
  const _AuthorRow();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        const Avatar(size: AvatarSize.small),
        const SizedBox(width: UIConstants.createEditorAvatarSpacing),
Text(
          AppStrings.createEditorAuthorYou,
          style: theme.textTheme.titleSmall,
        ),
      ],
    );
  }
}

/// Divisor sutil entre seções.
class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: UIConstants.createEditorSectionSpacing * 2,
      thickness: UIConstants.createEditorDividerThickness,
      color:
          Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
    );
  }
}

/// Campo de texto preenchido (fundo surfaceContainerHighest).
class _FilledField extends StatelessWidget {
  const _FilledField({
    required this.hint,
    this.prefixIcon,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
    this.controller,
  });

  final String hint;
  final Widget? prefixIcon;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        filled: true,
        fillColor: colors.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius:
              BorderRadius.circular(UIConstants.createEditorFieldRadius),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: UIConstants.spaceMd,
          vertical: UIConstants.spaceSm,
        ),
        prefixIcon: prefixIcon,
      ),
      readOnly: readOnly,
      onTap: onTap,
      controller: controller,
      onChanged: onChanged,
    );
  }
}

/// Seletor de visibilidade reutilizável.
class _VisibilityRow extends StatelessWidget {
  const _VisibilityRow({required this.provider, required this.draft});

  final CreatePostProvider provider;
  final PostDraft draft;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isPublic = draft.visibility == DraftVisibility.public;

    return Row(
      children: [
        Icon(Icons.visibility_outlined, size: UIConstants.createVisibilityIconSize, color: colors.onSurfaceVariant),
        const SizedBox(width: UIConstants.spaceXs),
        Text(
          AppStrings.createEditorVisibilityLabel,
          style: theme.textTheme.labelSmall
              ?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(width: UIConstants.spaceSm),
        ChoiceChip(
          label: const Text(AppStrings.createEditorVisibilityPublic),
          selected: isPublic,
          visualDensity: VisualDensity.compact,
          onSelected: (_) => provider.setVisibility(DraftVisibility.public),
        ),
        const SizedBox(width: UIConstants.spaceXs),
        ChoiceChip(
          label: const Text(AppStrings.createEditorVisibilityFriends),
          selected: !isPublic,
          visualDensity: VisualDensity.compact,
          onSelected: (_) =>
              provider.setVisibility(DraftVisibility.friendsOnly),
        ),
      ],
    );
  }
}

/// Bloco de mídia vazio com ícone + hint + botão.
class _EmptyMediaPlaceholder extends StatelessWidget {
  const _EmptyMediaPlaceholder({
    required this.icon,
    required this.hint,
    required this.buttonLabel,
    required this.onTap,
    this.aspectRatio = 1.0,
  });

  final IconData icon;
  final String hint;
  final String buttonLabel;
  final VoidCallback onTap;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(UIConstants.createEditorFieldRadius),
        child: Container(
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius:
                BorderRadius.circular(UIConstants.createEditorFieldRadius),
            border: Border.all(
              color: colors.outlineVariant,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: UIConstants.createEmptyMediaIconSize, color: colors.onSurfaceVariant),
              const SizedBox(height: UIConstants.spaceSm),
              Text(
                hint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: UIConstants.spaceMd),
              FilledButton.tonal(
                onPressed: onTap,
                child: Text(buttonLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// 1. POST — Twitter/X
// ===========================================================================

class _PostEditor extends StatelessWidget {
  const _PostEditor({required this.provider, required this.draft});

  final CreatePostProvider provider;
  final PostDraft draft;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: _editorPadding(context),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Avatar(size: AvatarSize.small),
            const SizedBox(width: UIConstants.createEditorAvatarSpacing),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: AppStrings.createPostBodyHint,
                  border: InputBorder.none,
                  hintStyle:
                      Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                ),
                style: Theme.of(context).textTheme.bodyLarge,
                autofocus: true,
                maxLines: null,
                minLines: 5,
                textCapitalization: TextCapitalization.sentences,
                onChanged: provider.setBody,
              ),
            ),
          ],
        ),
        const _SectionDivider(),
        _VisibilityRow(provider: provider, draft: draft),
      ],
    );
  }
}

// ===========================================================================
// 2. FOTO — Instagram
// ===========================================================================

class _PhotoEditor extends StatelessWidget {
  const _PhotoEditor({required this.provider, required this.draft});

  final CreatePostProvider provider;
  final PostDraft draft;

  Future<void> _openPicker(BuildContext context) =>
      showMediaPickerSheet(context);

  @override
  Widget build(BuildContext context) {
    final hasMedia = provider.mediaItems.isNotEmpty;

    return ListView(
      padding: _editorPadding(context),
      children: [
        // ── Carrossel / grid de fotos ──────────────────────────────────
        if (hasMedia) ...[
          _PhotoCarousel(items: provider.mediaItems),
          const SizedBox(height: UIConstants.createEditorSectionSpacing),
          MediaPreviewStrip(
            items: provider.mediaItems,
            onRemove: provider.removeMediaAt,
            onAdd: () => _openPicker(context),
          ),
        ] else
          _EmptyMediaPlaceholder(
            icon: Icons.add_photo_alternate_outlined,
            hint: AppStrings.createEditorAddMedia,
            buttonLabel: AppStrings.mediaPickerGallery,
            onTap: () => _openPicker(context),
            aspectRatio: UIConstants.createMediaPreviewAspectRatio,
          ),
        const _SectionDivider(),
        // ── Autor ──────────────────────────────────────────────────────
        const _AuthorRow(),
        const SizedBox(height: UIConstants.createEditorSectionSpacing),
        // ── Legenda ────────────────────────────────────────────────────
        TextField(
          decoration: InputDecoration(
            hintText: AppStrings.createPhotoCaption,
            border: InputBorder.none,
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          style: Theme.of(context).textTheme.bodyMedium,
          autofocus: !hasMedia,
          maxLines: null,
          minLines: 2,
          textCapitalization: TextCapitalization.sentences,
          onChanged: provider.setBody,
        ),
        const _SectionDivider(),
        // ── Metadados ──────────────────────────────────────────────────
        _IconRow(
          icon: Icons.place_outlined,
          label: AppStrings.createPhotoLocation,
          onTap: () {},
        ),
        const SizedBox(height: UIConstants.spaceSm),
        _IconRow(
          icon: Icons.person_add_outlined,
          label: AppStrings.createPhotoTagPeople,
          onTap: () {},
        ),
        const _SectionDivider(),
        _VisibilityRow(provider: provider, draft: draft),
      ],
    );
  }
}

/// Carrossel de fotos (paginado, aspect-ratio 4:3).
class _PhotoCarousel extends StatefulWidget {
  const _PhotoCarousel({required this.items});

  final List<XFile> items;

  @override
  State<_PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<_PhotoCarousel> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        AspectRatio(
          aspectRatio: UIConstants.createMediaPreviewAspectRatio,
          child: PageView.builder(
            itemCount: widget.items.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) => ClipRRect(
              borderRadius: BorderRadius.circular(
                UIConstants.createEditorFieldRadius,
              ),
              child: Image.file(
                File(widget.items[i].path),
                fit: BoxFit.cover,
                errorBuilder: (context, error, _) => Container(
                  color: colors.surfaceContainerHighest,
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (widget.items.length > 1) ...[
          const SizedBox(height: UIConstants.spaceSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.items.length; i++)
                AnimatedContainer(
                  duration: UIConstants.engagementColorDuration,
                  margin: const EdgeInsets.symmetric(
                    horizontal: UIConstants.space2xs,
                  ),
                  width: i == _page ? UIConstants.createCarouselActiveDotWidth : UIConstants.createCarouselDotSize,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: i == _page
                        ? colors.primary
                        : colors.outlineVariant,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Linha de ação com ícone e label (local, marcar pessoas…).
class _IconRow extends StatelessWidget {
  const _IconRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(UIConstants.createEditorFieldRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: UIConstants.spaceXs),
        child: Row(
          children: [
            Icon(icon, size: 20, color: colors.onSurfaceVariant),
            const SizedBox(width: UIConstants.spaceSm),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: colors.outlineVariant,
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// 3. VÍDEO — TikTok
// ===========================================================================

class _VideoEditor extends StatelessWidget {
  const _VideoEditor({required this.provider, required this.draft});

  final CreatePostProvider provider;
  final PostDraft draft;

  Future<void> _openPicker(BuildContext context) =>
      showMediaPickerSheet(context, allowVideo: true, maxItems: 1);

  @override
  Widget build(BuildContext context) {
    final hasMedia = provider.mediaItems.isNotEmpty;

    return ListView(
      padding: _editorPadding(context),
      children: [
        // ── Thumb do vídeo ─────────────────────────────────────────────
        if (hasMedia)
          Stack(
            children: [
              AspectRatio(
                aspectRatio: UIConstants.createMediaPreviewAspectRatio,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    UIConstants.createEditorFieldRadius,
                  ),
                  child: Image.file(
                    File(provider.mediaItems.first.path),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, _) => _VideoThumbPlaceholder(),
                  ),
                ),
              ),
              // Play overlay
              Positioned.fill(
                child: Center(
                  child: Container(
                    width: UIConstants.createVideoPlayOverlaySize,
                    height: UIConstants.createVideoPlayOverlaySize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: UIConstants.createVideoPlayIconSize,
                    ),
                  ),
                ),
              ),
              // Trocar vídeo
              Positioned(
                bottom: UIConstants.spaceSm,
                right: UIConstants.spaceSm,
                child: FilledButton.tonal(
                  onPressed: () => _openPicker(context),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text(AppStrings.createEditorAddMedia),
                ),
              ),
            ],
          )
        else
          _EmptyMediaPlaceholder(
            icon: Icons.videocam_outlined,
            hint: AppStrings.createEditorAddMedia,
            buttonLabel: AppStrings.mediaPickerGallery,
            onTap: () => _openPicker(context),
            aspectRatio: UIConstants.createMediaPreviewAspectRatio,
          ),
        const _SectionDivider(),
        // ── Autor ──────────────────────────────────────────────────────
        const _AuthorRow(),
        const SizedBox(height: UIConstants.createEditorSectionSpacing),
        // ── Título ─────────────────────────────────────────────────────
        TextField(
          decoration: InputDecoration(
            hintText: AppStrings.createVideoTitleHint,
            border: InputBorder.none,
            hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          style: Theme.of(context).textTheme.titleMedium,
          autofocus: !hasMedia,
          textCapitalization: TextCapitalization.sentences,
          onChanged: provider.setTitle,
        ),
        const SizedBox(height: UIConstants.createEditorSectionSpacing),
        // ── Descrição ──────────────────────────────────────────────────
        TextField(
          decoration: InputDecoration(
            hintText: AppStrings.createVideoDescriptionHint,
            border: InputBorder.none,
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          style: Theme.of(context).textTheme.bodyMedium,
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
          onChanged: provider.setBody,
        ),
        const _SectionDivider(),
        _IconRow(
          icon: Icons.place_outlined,
          label: AppStrings.createPhotoLocation,
          onTap: () {},
        ),
        const _SectionDivider(),
        _VisibilityRow(provider: provider, draft: draft),
      ],
    );
  }
}

class _VideoThumbPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      color: colors.surfaceContainerHighest,
      child: Icon(
        Icons.videocam_outlined,
        color: colors.onSurfaceVariant,
        size: 48,
      ),
    );
  }
}

// ===========================================================================
// 4. ÁUDIO — Podcast-like
// ===========================================================================

class _AudioEditor extends StatelessWidget {
  const _AudioEditor({required this.provider, required this.draft});

  final CreatePostProvider provider;
  final PostDraft draft;

  String get _durationLabel {
    final d = draft.audioDuration;
    if (d == Duration.zero) return '--:--';
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasAudio = draft.audioDuration.inSeconds > 0;

    return ListView(
      padding: _editorPadding(context),
      children: [
        // ── Player preview ─────────────────────────────────────────────
        Container(
          height: UIConstants.createAudioPlayerHeight,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius:
                BorderRadius.circular(UIConstants.createEditorFieldRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.spaceMd,
            vertical: UIConstants.spaceSm,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary,
                ),
                child: Icon(
                  hasAudio ? Icons.play_arrow_rounded : Icons.mic_rounded,
                  color: colors.onPrimary,
                ),
              ),
              const SizedBox(width: UIConstants.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      draft.title.isEmpty
                          ? AppStrings.createAudioTitleHint
                          : draft.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: colors.onPrimaryContainer,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: UIConstants.space2xs),
                    // Waveform placeholder
                    Row(
                      children: [
                        for (var i = 0; i < UIConstants.createAudioWaveBarCount; i++)
                          Container(
                            width: UIConstants.createAudioWaveBarWidth,
                            height: (i % 3 == 0
                                    ? UIConstants.createAudioWaveBarMaxHeight
                                    : i % 2 == 0
                                        ? UIConstants.createAudioWaveBarMidHeight
                                        : UIConstants.createAudioWaveBarMinHeight),
                            margin: const EdgeInsets.symmetric(
                              horizontal:
                                  UIConstants.createAudioWaveBarSpacing / 2,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(
                                alpha: hasAudio ? 0.6 : 0.3,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: UIConstants.spaceSm),
              Text(
                _durationLabel,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colors.onPrimaryContainer,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
              ),
            ],
          ),
        ),
        const _SectionDivider(),
        // ── Autor ──────────────────────────────────────────────────────
        const _AuthorRow(),
        const SizedBox(height: UIConstants.createEditorSectionSpacing),
        // ── Título obrigatório ─────────────────────────────────────────
        TextField(
          decoration: InputDecoration(
            hintText: AppStrings.createAudioTitleHint,
            border: InputBorder.none,
            hintStyle:
                Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
          ),
          style: Theme.of(context).textTheme.titleMedium,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          onChanged: provider.setTitle,
        ),
        const SizedBox(height: UIConstants.createEditorSectionSpacing),
        TextField(
          decoration: InputDecoration(
            hintText: AppStrings.createAudioDescriptionHint,
            border: InputBorder.none,
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),
          style: Theme.of(context).textTheme.bodyMedium,
          maxLines: null,
          minLines: 3,
          textCapitalization: TextCapitalization.sentences,
          onChanged: provider.setBody,
        ),
        const _SectionDivider(),
        _VisibilityRow(provider: provider, draft: draft),
      ],
    );
  }
}

// ===========================================================================
// 5. STORY — Snapchat/Instagram
// ===========================================================================

class _StoryEditor extends StatelessWidget {
  const _StoryEditor({required this.provider, required this.draft});

  final CreatePostProvider provider;
  final PostDraft draft;

  Future<void> _openPicker(BuildContext context) =>
      showMediaPickerSheet(context, allowVideo: true, maxItems: 1);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasMedia = provider.mediaItems.isNotEmpty;

    return ListView(
      padding: _editorPadding(context),
      children: [
        // ── Preview 9:16 ───────────────────────────────────────────────
        AspectRatio(
          aspectRatio: 1 / UIConstants.createStoryPreviewAspectRatio,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              UIConstants.createEditorFieldRadius,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Fundo
                if (hasMedia)
                  Image.file(
                    File(provider.mediaItems.first.path),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, _) => ColoredBox(
                      color: colors.surfaceContainerHighest,
                    ),
                  )
                else
                  InkWell(
                    onTap: () => _openPicker(context),
                    child: Container(
                      color: colors.surfaceContainerHighest,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 48,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(height: UIConstants.spaceSm),
                          Text(
                            AppStrings.createStoryAddMediaHint,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                // Badge de expiração
                Positioned(
                  top: UIConstants.spaceSm,
                  left: UIConstants.spaceSm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: UIConstants.spaceSm,
                      vertical: UIConstants.space2xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(
                        UIConstants.createEditorFieldRadius,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: UIConstants.createStoryBadgeIconSize,
                          color: Colors.white,
                        ),
                        const SizedBox(width: UIConstants.space2xs),
                        const Text(
                          AppStrings.createStoryExpiry,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: UIConstants.createStoryBadgeFontSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Botão adicionar mídia (sobreposto)
                if (hasMedia)
                  Positioned(
                    bottom: UIConstants.spaceSm,
                    right: UIConstants.spaceSm,
                    child: FilledButton.tonal(
                      onPressed: () => _openPicker(context),
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text(AppStrings.createEditorAddMedia),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const _SectionDivider(),
        // ── Texto sobreposto ───────────────────────────────────────────
        TextField(
          decoration: InputDecoration(
            hintText: AppStrings.createStoryTextOverlay,
            border: InputBorder.none,
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),
          style: Theme.of(context).textTheme.bodyMedium,
          autofocus: false,
          maxLines: UIConstants.createStoryTextMaxLines,
          textCapitalization: TextCapitalization.sentences,
          onChanged: provider.setBody,
        ),
        const _SectionDivider(),
        _VisibilityRow(provider: provider, draft: draft),
      ],
    );
  }
}

// ===========================================================================
// 6. ARTIGO — Medium
// ===========================================================================

class _ArticleEditor extends StatelessWidget {
  const _ArticleEditor({required this.provider, required this.draft});

  final CreatePostProvider provider;
  final PostDraft draft;

  Future<void> _openCoverPicker(BuildContext context) =>
      showMediaPickerSheet(context, allowVideo: false, maxItems: 1);

  int get _estimatedReadMinutes {
    final words = draft.body.trim().split(RegExp(r'\s+')).length;
    return (words / UIConstants.createArticleWpm).ceil().clamp(1, 99);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasCover = provider.mediaItems.isNotEmpty;

    return ListView(
      padding: _editorPadding(context),
      children: [
        // ── Imagem de capa ─────────────────────────────────────────────
        if (hasCover)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  UIConstants.createEditorFieldRadius,
                ),
                child: SizedBox(
                  height: UIConstants.createArticleCoverHeight,
                  width: double.infinity,
                  child: Image.file(
                    File(provider.mediaItems.first.path),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, _) => Container(
                      color: colors.surfaceContainerHighest,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: UIConstants.spaceSm,
                right: UIConstants.spaceSm,
                child: FilledButton.tonal(
                  onPressed: () => _openCoverPicker(context),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text(AppStrings.createArticleCoverImage),
                ),
              ),
            ],
          )
        else
          OutlinedButton.icon(
            onPressed: () => _openCoverPicker(context),
            icon: const Icon(Icons.image_outlined),
            label: const Text(AppStrings.createArticleCoverImage),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  UIConstants.createEditorMediaAddRadius,
                ),
              ),
              minimumSize: const Size(double.infinity, UIConstants.createEditorButtonMinHeight),
            ),
          ),
        const SizedBox(height: UIConstants.createEditorSectionSpacing),
        // ── Título grande ──────────────────────────────────────────────
        TextField(
          decoration: InputDecoration(
            hintText: AppStrings.createArticleTitleHint,
            border: InputBorder.none,
            hintStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),
          style: Theme.of(context).textTheme.headlineMedium,
          autofocus: true,
          maxLines: null,
          textCapitalization: TextCapitalization.sentences,
          onChanged: provider.setTitle,
        ),
        // ── Subtítulo ──────────────────────────────────────────────────
        TextField(
          decoration: InputDecoration(
            hintText: AppStrings.createArticleSubtitleHint,
            border: InputBorder.none,
            hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),
          style: Theme.of(context).textTheme.titleMedium,
          maxLines: null,
          textCapitalization: TextCapitalization.sentences,
          onChanged: provider.setSubtitle,
        ),
        const _SectionDivider(),
        // ── Autor + read time ──────────────────────────────────────────
        Row(
          children: [
            const Avatar(size: AvatarSize.small),
            const SizedBox(width: UIConstants.createEditorAvatarSpacing),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.createEditorAuthorYou,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (draft.body.trim().isNotEmpty)
                  Text(
                    AppStrings.createArticleReadTime.replaceAll(
                      '{min}',
                      '$_estimatedReadMinutes',
                    ),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                  ),
              ],
            ),
          ],
        ),
        const _SectionDivider(),
        // ── Corpo ──────────────────────────────────────────────────────
        TextField(
          decoration: InputDecoration(
            hintText: AppStrings.createArticleBodyHint,
            border: InputBorder.none,
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: UIConstants.postArticleBodyLineHeight,
              ),
          maxLines: null,
          minLines: UIConstants.createArticleBodyMinLines,
          textCapitalization: TextCapitalization.sentences,
          onChanged: provider.setBody,
        ),
        const _SectionDivider(),
        _VisibilityRow(provider: provider, draft: draft),
      ],
    );
  }
}

// ===========================================================================
// 7. ENQUETE — Twitter
// ===========================================================================

class _PollEditor extends StatelessWidget {
  const _PollEditor({required this.provider, required this.draft});

  final CreatePostProvider provider;
  final PostDraft draft;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final options = draft.pollOptions;

    return ListView(
      padding: _editorPadding(context),
      children: [
        const _AuthorRow(),
        const SizedBox(height: UIConstants.createEditorSectionSpacing),
        // ── Pergunta ───────────────────────────────────────────────────
        TextField(
          decoration: InputDecoration(
            hintText: AppStrings.createPollQuestionHint,
            border: InputBorder.none,
            hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),
          style: Theme.of(context).textTheme.titleMedium,
          autofocus: true,
          maxLines: null,
          textCapitalization: TextCapitalization.sentences,
          onChanged: provider.setBody,
        ),
        const _SectionDivider(),
        // ── Opções com preview de barra ────────────────────────────────
        for (var i = 0; i < options.length; i++) ...[
          _PollOptionRow(
            index: i,
            provider: provider,
            canRemove: options.length > UIConstants.createPollMinOptions,
          ),
          const SizedBox(height: UIConstants.createEditorPollSpacing),
        ],
        // Adicionar opção (máx 4)
        if (options.length < UIConstants.createPollMaxOptions)
          TextButton.icon(
            onPressed: provider.addPollOption,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text(AppStrings.createEditorAddPollOption),
          ),
        const _SectionDivider(),
        // ── Duração ────────────────────────────────────────────────────
        Row(
          children: [
            Icon(Icons.timer_outlined,
                size: UIConstants.createEditorInlineIconSize, color: colors.onSurfaceVariant),
            const SizedBox(width: UIConstants.spaceSm),
            Text(
              AppStrings.createPollDuration,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
            const Spacer(),
            for (final entry in {
              1: AppStrings.createPollDuration1d,
              3: AppStrings.createPollDuration3d,
              7: AppStrings.createPollDuration7d,
            }.entries)
              Padding(
                padding:
                    const EdgeInsets.only(left: UIConstants.spaceXs),
                child: ChoiceChip(
                  label: Text(entry.value),
                  selected: draft.pollDurationDays == entry.key,
                  visualDensity: VisualDensity.compact,
                  onSelected: (_) =>
                      provider.setPollDurationDays(entry.key),
                ),
              ),
          ],
        ),
        const _SectionDivider(),
        _VisibilityRow(provider: provider, draft: draft),
      ],
    );
  }
}

class _PollOptionRow extends StatelessWidget {
  const _PollOptionRow({
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
    final hint = AppStrings.createPollOption.replaceAll(
      '{n}',
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
            icon: const Icon(Icons.close_rounded),
            iconSize: 18,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ],
    );
  }
}

// ===========================================================================
// 8. EVENTO — Google Calendar
// ===========================================================================

class _EventEditor extends StatefulWidget {
  const _EventEditor({required this.provider, required this.draft});

  final CreatePostProvider provider;
  final PostDraft draft;

  @override
  State<_EventEditor> createState() => _EventEditorState();
}

class _EventEditorState extends State<_EventEditor> {
  late final TextEditingController _dateCtrl =
      TextEditingController(text: widget.draft.eventDate);

  @override
  void dispose() {
    _dateCtrl.dispose();
    super.dispose();
  }

  Future<void> _openPicker(BuildContext context) =>
      showMediaPickerSheet(context, allowVideo: false, maxItems: 1);

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final draft = widget.draft;
    final colors = Theme.of(context).colorScheme;
    final hasBanner = provider.mediaItems.isNotEmpty;

    return ListView(
      padding: _editorPadding(context),
      children: [
        // ── Banner ─────────────────────────────────────────────────────
        if (hasBanner)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  UIConstants.createEditorFieldRadius,
                ),
                child: SizedBox(
                  height: UIConstants.createEventBannerHeight,
                  width: double.infinity,
                  child: Image.file(
                    File(provider.mediaItems.first.path),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, _) => Container(
                        color: colors.tertiaryContainer),
                  ),
                ),
              ),
              Positioned(
                bottom: UIConstants.spaceSm,
                right: UIConstants.spaceSm,
                child: FilledButton.tonal(
                  onPressed: () => _openPicker(context),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text(AppStrings.createEventBanner),
                ),
              ),
            ],
          )
        else
          OutlinedButton.icon(
            onPressed: () => _openPicker(context),
            icon: const Icon(Icons.image_outlined),
            label: const Text(AppStrings.createEventBanner),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  UIConstants.createEditorMediaAddRadius,
                ),
              ),
              minimumSize:
                  const Size(double.infinity, UIConstants.createEventBannerHeight / 2),
            ),
          ),
        const SizedBox(height: UIConstants.createEditorSectionSpacing),
        // ── Título ─────────────────────────────────────────────────────
        TextField(
          decoration: InputDecoration(
            hintText: AppStrings.createEventTitleHint,
            border: InputBorder.none,
            hintStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),
          style: Theme.of(context).textTheme.headlineSmall,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          onChanged: provider.setTitle,
        ),
        const _SectionDivider(),
        // ── Formato ────────────────────────────────────────────────────
        Row(
          children: [
            Icon(Icons.location_on_outlined,
                size: UIConstants.createEditorInlineIconSize, color: colors.onSurfaceVariant),
            const SizedBox(width: UIConstants.spaceSm),
            Text(
              AppStrings.createEventFormat,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
            const Spacer(),
            ChoiceChip(
              label: const Text(AppStrings.createEventInPerson),
              selected: !draft.eventIsOnline,
              visualDensity: VisualDensity.compact,
              onSelected: (_) => provider.setEventIsOnline(false),
            ),
            const SizedBox(width: UIConstants.spaceXs),
            ChoiceChip(
              label: const Text(AppStrings.createEventOnline),
              selected: draft.eventIsOnline,
              visualDensity: VisualDensity.compact,
              onSelected: (_) => provider.setEventIsOnline(true),
            ),
          ],
        ),
        const SizedBox(height: UIConstants.createEditorSectionSpacing),
        // ── Data ───────────────────────────────────────────────────────
        _FilledField(
          hint: AppStrings.createEventDateHint,
          prefixIcon: const Icon(Icons.calendar_today_outlined),
          readOnly: true,
          controller: _dateCtrl,
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
            );
            if (picked != null) {
              final formatted =
                  '${picked.day.toString().padLeft(2, '0')}/'
                  '${picked.month.toString().padLeft(2, '0')}/'
                  '${picked.year}';
              _dateCtrl.text = formatted;
              provider.setEventDate(formatted);
            }
          },
        ),
        const SizedBox(height: UIConstants.createEditorSectionSpacing),
        // ── Local ──────────────────────────────────────────────────────
        _FilledField(
          hint: AppStrings.createEventLocationHint,
          prefixIcon: const Icon(Icons.place_outlined),
          onChanged: provider.setEventLocation,
        ),
        const _SectionDivider(),
        // ── Descrição ──────────────────────────────────────────────────
        TextField(
          decoration: InputDecoration(
            hintText: AppStrings.createEventDescHint,
            border: InputBorder.none,
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),
          style: Theme.of(context).textTheme.bodyMedium,
          maxLines: null,
          minLines: 3,
          textCapitalization: TextCapitalization.sentences,
          onChanged: provider.setBody,
        ),
        const _SectionDivider(),
        _VisibilityRow(provider: provider, draft: draft),
      ],
    );
  }
}

// ===========================================================================
// 9. LIVE — YouTube
// ===========================================================================

class _LiveEditor extends StatefulWidget {
  const _LiveEditor({required this.provider, required this.draft});

  final CreatePostProvider provider;
  final PostDraft draft;

  @override
  State<_LiveEditor> createState() => _LiveEditorState();
}

class _LiveEditorState extends State<_LiveEditor> {
  late final TextEditingController _schedDateCtrl =
      TextEditingController(text: widget.draft.liveScheduledDate);

  @override
  void dispose() {
    _schedDateCtrl.dispose();
    super.dispose();
  }

  Future<void> _openThumbPicker(BuildContext context) =>
      showMediaPickerSheet(context, allowVideo: false, maxItems: 1);

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final draft = widget.draft;
    final colors = Theme.of(context).colorScheme;
    final hasThumb = provider.mediaItems.isNotEmpty;

    return ListView(
      padding: _editorPadding(context),
      children: [
        // ── Thumbnail ──────────────────────────────────────────────────
        if (hasThumb)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  UIConstants.createEditorFieldRadius,
                ),
                child: SizedBox(
                  height: UIConstants.createLiveThumbnailHeight,
                  width: double.infinity,
                  child: Image.file(
                    File(provider.mediaItems.first.path),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, _) => Container(
                        color: colors.errorContainer),
                  ),
                ),
              ),
              // Live badge
              Positioned(
                top: UIConstants.spaceSm,
                left: UIConstants.spaceSm,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UIConstants.spaceSm,
                    vertical: UIConstants.space2xs,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.circular(
                      UIConstants.createEditorFieldRadius,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: UIConstants.createLiveBadgeDotSize, color: Colors.white),
                      SizedBox(width: UIConstants.space2xs),
                      Text(
                        AppStrings.createLiveBadgeLabel,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: UIConstants.createLiveBadgeFontSize,
                          fontWeight: FontWeight.bold,
                          letterSpacing: UIConstants.createLiveBadgeLetterSpacing,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: UIConstants.spaceSm,
                right: UIConstants.spaceSm,
                child: FilledButton.tonal(
                  onPressed: () => _openThumbPicker(context),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text(AppStrings.createLiveThumbnail),
                ),
              ),
            ],
          )
        else
          OutlinedButton.icon(
            onPressed: () => _openThumbPicker(context),
            icon: const Icon(Icons.image_outlined),
            label: const Text(AppStrings.createLiveThumbnail),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  UIConstants.createEditorMediaAddRadius,
                ),
              ),
              minimumSize: const Size(
                double.infinity,
                UIConstants.createLiveThumbnailHeight,
              ),
            ),
          ),
        const SizedBox(height: UIConstants.createEditorSectionSpacing),
        // ── Título ─────────────────────────────────────────────────────
        TextField(
          decoration: InputDecoration(
            hintText: AppStrings.createLiveTitleHint,
            border: InputBorder.none,
            hintStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),
          style: Theme.of(context).textTheme.titleLarge,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          onChanged: provider.setTitle,
        ),
        const SizedBox(height: UIConstants.createEditorSectionSpacing),
        TextField(
          decoration: InputDecoration(
            hintText: AppStrings.createLiveDescHint,
            border: InputBorder.none,
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),
          style: Theme.of(context).textTheme.bodyMedium,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          onChanged: provider.setBody,
        ),
        const _SectionDivider(),
        // ── Categoria ──────────────────────────────────────────────────
        _FilledField(
          hint: AppStrings.createLiveCategoryHint,
          prefixIcon: const Icon(Icons.category_outlined),
          onChanged: provider.setLiveCategory,
        ),
        const _SectionDivider(),
        // ── Agendamento ────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _ScheduleChip(
                label: AppStrings.createLiveScheduleNow,
                icon: Icons.live_tv_rounded,
                selected: draft.isLiveNow,
                onTap: () => provider.setIsLiveNow(true),
              ),
            ),
            const SizedBox(width: UIConstants.spaceSm),
            Expanded(
              child: _ScheduleChip(
                label: AppStrings.createLiveSchedule,
                icon: Icons.schedule_rounded,
                selected: !draft.isLiveNow,
                onTap: () => provider.setIsLiveNow(false),
              ),
            ),
          ],
        ),
        if (!draft.isLiveNow) ...[
          const SizedBox(height: UIConstants.createEditorSectionSpacing),
          _FilledField(
            hint: AppStrings.createEventDateHint,
            prefixIcon: const Icon(Icons.calendar_today_outlined),
            readOnly: true,
            controller: _schedDateCtrl,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate:
                    DateTime.now().add(const Duration(days: 90)),
              );
              if (picked != null) {
                final formatted =
                    '${picked.day.toString().padLeft(2, '0')}/'
                    '${picked.month.toString().padLeft(2, '0')}/'
                    '${picked.year}';
                _schedDateCtrl.text = formatted;
                provider.setLiveScheduledDate(formatted);
              }
            },
          ),
        ],
        const _SectionDivider(),
        // ── Aviso ──────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.spaceMd,
            vertical: UIConstants.spaceSm,
          ),
          decoration: BoxDecoration(
            color: colors.errorContainer,
            borderRadius:
                BorderRadius.circular(UIConstants.createEditorFieldRadius),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  color: colors.onErrorContainer, size: UIConstants.createEditorInlineIconSize),
              const SizedBox(width: UIConstants.spaceSm),
              Expanded(
                child: Text(
                  AppStrings.createLiveWarning,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onErrorContainer,
                      ),
                ),
              ),
            ],
          ),
        ),
        const _SectionDivider(),
        _VisibilityRow(provider: provider, draft: draft),
      ],
    );
  }
}

class _ScheduleChip extends StatelessWidget {
  const _ScheduleChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(UIConstants.createEditorFieldRadius),
      child: AnimatedContainer(
        duration: UIConstants.engagementColorDuration,
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.spaceMd,
          vertical: UIConstants.spaceSm,
        ),
        decoration: BoxDecoration(
          color: selected ? colors.primaryContainer : colors.surfaceContainerHighest,
          borderRadius:
              BorderRadius.circular(UIConstants.createEditorFieldRadius),
          border: selected
              ? Border.all(color: colors.primary, width: UIConstants.createScheduleChipBorderWidth)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: UIConstants.createScheduleChipIconSize,
              color: selected ? colors.primary : colors.onSurfaceVariant,
            ),
            const SizedBox(width: UIConstants.spaceXs),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: selected
                          ? colors.primary
                          : colors.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
