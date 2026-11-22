import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../provider/create/create_post_provider.dart';
import '../../../service/media_picker_service.dart';
import '../../../util/const/app/app_strings.dart';
import '../../../util/const/ui/ui_constants.dart';

/// Chama o sheet de mídia (galeria pura) em modal bottom.
/// Retorna quando o usuário fecha (seleciona ou cancela).
Future<void> showMediaPickerSheet(
  BuildContext context, {
  bool allowVideo = true,
  int maxItems = 10,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<CreatePostProvider>(),
      child: _MediaPickerSheet(allowVideo: allowVideo, maxItems: maxItems),
    ),
  );
}

class _MediaPickerSheet extends StatefulWidget {
  const _MediaPickerSheet({required this.allowVideo, required this.maxItems});
  final bool allowVideo;
  final int maxItems;

  @override
  State<_MediaPickerSheet> createState() => _MediaPickerSheetState();
}

class _MediaPickerSheetState extends State<_MediaPickerSheet> {
  final _pickerService = MediaPickerService();

  Future<void> _pickFromGallery() async {
    final provider = context.read<CreatePostProvider>();
    final remaining = widget.maxItems - provider.mediaCount;
    if (remaining <= 0) {
      _showMaxSnack();
      return;
    }
    final files = widget.allowVideo
        ? await _pickerService.pickMedia(maxItems: remaining)
        : await _pickerService.pickPhotos(maxItems: remaining);
    if (!mounted) return;
    if (files.isNotEmpty) {
      provider.addMediaItems(files);
      Navigator.of(context).pop();
    }
  }

  void _showMaxSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppStrings.mediaPickerMaxSelection.replaceAll(
            '{max}',
            '${widget.maxItems}',
          ),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: UIConstants.mediaPickerSheetInitialFraction,
      minChildSize: UIConstants.mediaPickerSheetMinFraction,
      maxChildSize: UIConstants.mediaPickerSheetMaxFraction,
      expand: false,
      snap: true,
      snapSizes: const [
        UIConstants.mediaPickerSheetInitialFraction,
        UIConstants.mediaPickerSheetMaxFraction,
      ],
      builder: (context, scrollController) => ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(UIConstants.radiusLg),
        ),
        child: Scaffold(
          backgroundColor: colors.surface,
          body: Column(
            children: [
              // ── Drag handle ──
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: UIConstants.spaceSm,
                ),
                child: Center(
                  child: Container(
                    width: UIConstants.mediaPickerDragHandleWidth,
                    height: UIConstants.mediaPickerDragHandleHeight,
                    decoration: BoxDecoration(
                      color: colors.onSurfaceVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(
                        UIConstants.mediaPickerDragHandleRadius,
                      ),
                    ),
                  ),
                ),
              ),

              // ── AppBar leve ──
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.spaceMd,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppStrings.mediaPickerGallery,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      tooltip: AppStrings.mediaPickerCancel,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // ── Conteúdo ──
              Expanded(
                child: _GalleryBody(
                  scrollController: scrollController,
                  maxItems: widget.maxItems,
                  onPick: _pickFromGallery,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Corpo de galeria
// ---------------------------------------------------------------------------

class _GalleryBody extends StatelessWidget {
  const _GalleryBody({
    required this.scrollController,
    required this.maxItems,
    required this.onPick,
  });

  final ScrollController scrollController;
  final int maxItems;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CreatePostProvider>();
    final items = provider.mediaItems;

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        if (items.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.spaceMd,
              vertical: UIConstants.spaceSm,
            ),
            sliver: SliverGrid.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: UIConstants.mediaPickerGridColumns.toInt(),
                crossAxisSpacing: UIConstants.mediaPickerGridSpacing,
                mainAxisSpacing: UIConstants.mediaPickerGridSpacing,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) => _GridThumb(
                file: items[i],
                index: i,
                onRemove: () => provider.removeMediaAt(i),
              ),
            ),
          ),

        // ── Botão de abertura do picker nativo ──
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.spaceLg,
              vertical: UIConstants.spaceLg,
            ),
            child: Column(
              mainAxisAlignment: items.isEmpty
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.end,
              children: [
                if (items.isEmpty) ...[
                  Icon(
                    Icons.photo_library_outlined,
                    size: UIConstants.createTypeIconSize * 2,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: UIConstants.spaceMd),
                  Text(
                    AppStrings.mediaPickerGallery,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: UIConstants.spaceXs),
                  Text(
                    AppStrings.mediaPickerGalleryHint,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color:
                          Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: UIConstants.spaceLg),
                ],
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onPick,
                    icon: const Icon(Icons.photo_library_rounded),
                    label: const Text(AppStrings.mediaPickerDone),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Thumbnail do grid (maior que o strip — usa largura automática do grid)
// ---------------------------------------------------------------------------

class _GridThumb extends StatelessWidget {
  const _GridThumb({
    required this.file,
    required this.index,
    required this.onRemove,
  });

  final XFile file;
  final int index;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius:
              BorderRadius.circular(UIConstants.mediaPickerThumbRadius),
          child: Image.file(
            File(file.path),
            fit: BoxFit.cover,
            errorBuilder: (context, error, _) => ColoredBox(
              color: colors.surfaceContainerHighest,
              child: Icon(
                Icons.broken_image_outlined,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ),
        // Botão remover
        Positioned(
          top: UIConstants.mediaThumbBadgeOffset,
          right: UIConstants.mediaThumbBadgeOffset,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: UIConstants.mediaPickerSelectionBadgeSize,
              height: UIConstants.mediaPickerSelectionBadgeSize,
              decoration: BoxDecoration(
                color: colors.error,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: UIConstants.mediaPickerBadgeIconSize, color: colors.onError),
            ),
          ),
        ),
        // Número de ordem
        Positioned(
          bottom: UIConstants.mediaThumbBadgeOffset,
          left: UIConstants.mediaThumbBadgeOffset,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.space2xs,
              vertical: UIConstants.mediaPickerBadgePaddingVertical,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius:
                  BorderRadius.circular(UIConstants.space2xs),
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: UIConstants.mediaPickerBadgeFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
