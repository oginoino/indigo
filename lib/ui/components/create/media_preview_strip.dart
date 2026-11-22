import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../../util/const/app/app_strings.dart';
import '../../../util/const/ui/ui_constants.dart';

/// Faixa horizontal de thumbnails das mídias selecionadas.
///
/// Exibe até [maxItems] itens com botão × para remover. Ao final,
/// exibe um botão + para adicionar mais.
class MediaPreviewStrip extends StatelessWidget {
  const MediaPreviewStrip({
    required this.items,
    required this.onRemove,
    required this.onAdd,
    this.maxItems = 10,
    super.key,
  });

  final List<XFile> items;
  final ValueChanged<int> onRemove;
  final VoidCallback onAdd;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final canAdd = items.length < maxItems;

    return SizedBox(
      height: UIConstants.createEditorMediaPreviewSize + UIConstants.spaceMd,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: UIConstants.spaceXs),
        children: [
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: UIConstants.spaceXs),
              child: _Thumb(
                file: items[i],
                index: i,
                onRemove: () => onRemove(i),
              ),
            ),
          if (canAdd)
            Semantics(
              button: true,
              label: AppStrings.createEditorAddMedia,
              child: GestureDetector(
                onTap: onAdd,
                child: Container(
                  width: UIConstants.createEditorMediaPreviewSize,
                  height: UIConstants.createEditorMediaPreviewSize,
                  margin: const EdgeInsets.only(right: UIConstants.spaceXs),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(
                      UIConstants.mediaPickerThumbRadius,
                    ),
                    border: Border.all(color: colors.outlineVariant),
                  ),
                  child: Icon(
                    Icons.add_photo_alternate_outlined,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({
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

    return Semantics(
      label: AppStrings.createEditorMediaNth.replaceAll('{n}', '${index + 1}'),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(UIConstants.mediaPickerThumbRadius),
            child: Image.file(
              File(file.path),
              width: UIConstants.createEditorMediaPreviewSize,
              height: UIConstants.createEditorMediaPreviewSize,
              fit: BoxFit.cover,
              errorBuilder: (context, error, _) => Container(
                width: UIConstants.createEditorMediaPreviewSize,
                height: UIConstants.createEditorMediaPreviewSize,
                color: colors.surfaceContainerHighest,
                child: Icon(
                  Icons.broken_image_outlined,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
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
                borderRadius: BorderRadius.circular(UIConstants.space2xs),
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
      ),
    );
  }
}
