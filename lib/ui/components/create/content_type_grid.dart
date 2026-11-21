import 'package:material_ui/material_ui.dart';

import '../../../model/create/content_type.dart';
import '../../../util/const/app/app_strings.dart';
import '../../../util/const/ui/ui_constants.dart';

/// Grade de seleção do tipo de conteúdo a ser criado.
///
/// Exibe todos os [ContentType] em um grid de 3 colunas com ícone, label
/// e descrição. O tipo selecionado é destacado com a cor secundária do tema.
class ContentTypeGrid extends StatelessWidget {
  const ContentTypeGrid({
    required this.selected,
    required this.onSelect,
    super.key,
  });

  final ContentType selected;
  final ValueChanged<ContentType> onSelect;

  @override
  Widget build(BuildContext context) {
    final types = ContentType.values;

    return Padding(
      padding: const EdgeInsets.all(UIConstants.createTypeGridPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.createTypeSelectionTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: UIConstants.createTypeGridSpacing),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: types.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: UIConstants.createTypeGridColumns.toInt(),
              crossAxisSpacing: UIConstants.createTypeGridSpacing,
              mainAxisSpacing: UIConstants.createTypeGridSpacing,
              childAspectRatio: UIConstants.createTypeGridChildAspectRatio,
            ),
            itemBuilder: (context, index) =>
                _ContentTypeCard(
                  type: types[index],
                  isSelected: types[index] == selected,
                  onTap: () => onSelect(types[index]),
                ),
          ),
        ],
      ),
    );
  }
}

class _ContentTypeCard extends StatelessWidget {
  const _ContentTypeCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final ContentType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final bgColor = isSelected
        ? colors.secondaryContainer
        : colors.surfaceContainerHighest;
    final fgColor = isSelected ? colors.onSecondaryContainer : colors.onSurface;
    final iconColor = isSelected
        ? colors.onSecondaryContainer
        : colors.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '${type.label}: ${type.description}',
      child: AnimatedContainer(
        duration: UIConstants.bottomNavigationAnimationDuration,
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(UIConstants.createTypeCardRadius),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(UIConstants.createTypeCardRadius),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(
              UIConstants.createTypeCardRadius,
            ),
            child: Padding(
              padding: const EdgeInsets.all(UIConstants.spaceMd),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSelected ? type.activeIcon : type.icon,
                    size: UIConstants.createTypeIconSize,
                    color: iconColor,
                  ),
                  const SizedBox(height: UIConstants.createTypeCardLabelSpacing),
                  Text(
                    type.label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: fgColor,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    type.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: fgColor.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
