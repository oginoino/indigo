import 'dart:ui';

import 'package:material_ui/material_ui.dart';

import '../../util/const/app/app_strings.dart';
import '../../util/const/ui/ui_constants.dart';
import '../theme/app_component_theme.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.compact = false,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final navTheme = theme.bottomNavigationBarTheme;
    final componentTheme = theme.extension<AppComponentTheme>();

    final selectedColor = navTheme.selectedItemColor ?? colors.onSurface;

    final unselectedColor = navTheme.unselectedItemColor ?? colors.onSurface;

    final backgroundColor = navTheme.backgroundColor ?? colors.surface;
    final selectedBackgroundColor =
        componentTheme?.bottomNavigationSelectionColor ??
        colors.secondaryContainer;
    final borderColor =
        componentTheme?.bottomNavigationBorderColor ?? colors.outlineVariant;

    final selectedIndex = currentIndex >= 0 && currentIndex < items.length
        ? currentIndex
        : -1;

    final isScrollable =
        items.length > UIConstants.bottomNavigationMaxVisibleItems;

    final children = List<Widget>.generate(items.length, (index) {
      final item = items[index];
      final selected = index == selectedIndex;

      final configuredIconTheme = selected
          ? navTheme.selectedIconTheme
          : navTheme.unselectedIconTheme;

      final iconTheme = (configuredIconTheme ?? theme.iconTheme).copyWith(
        color: selected ? selectedColor : unselectedColor,
        size: compact
            ? UIConstants.bottomNavigationCompactIconSize
            : UIConstants.navigationIconSize,
      );

      final button = Semantics(
        button: true,
        selected: selected,
        label: item.label,
        child: Tooltip(
          message: item.label ?? AppStrings.empty,
          child: InkWell(
            onTap: () => onTap(index),
            borderRadius: BorderRadius.circular(
              UIConstants.bottomNavigationRadius,
            ),
            child: AnimatedContainer(
              duration: UIConstants.bottomNavigationAnimationDuration,
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                color: selected ? selectedBackgroundColor : Colors.transparent,
                borderRadius: BorderRadius.circular(
                  UIConstants.bottomNavigationRadius,
                ),
              ),
              child: Center(
                child: IconTheme(
                  data: iconTheme,
                  child: selected ? item.activeIcon : item.icon,
                ),
              ),
            ),
          ),
        ),
      );

      if (isScrollable) {
        return SizedBox(
          key: ValueKey(index),
          width: UIConstants.bottomNavigationItemWidth,
          child: button,
        );
      }

      return Expanded(key: ValueKey(index), child: button);
    }, growable: false);

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(
        left: UIConstants.bottomNavigationOuterPadding,
        right: UIConstants.bottomNavigationOuterPadding,
        bottom: UIConstants.bottomNavigationBottomPadding,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(UIConstants.bottomNavigationRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: UIConstants.bottomNavigationBlurSigma,
            sigmaY: UIConstants.bottomNavigationBlurSigma,
          ),
          child: AnimatedContainer(
            duration: UIConstants.bottomNavigationAnimationDuration,
            curve: Curves.easeOutCubic,
            height: compact
                ? UIConstants.bottomNavigationCompactHeight
                : UIConstants.bottomNavigationHeight,
            padding: const EdgeInsets.all(
              UIConstants.bottomNavigationContentPadding,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(
                UIConstants.bottomNavigationRadius,
              ),
              border: Border.all(color: borderColor),
            ),
            child: isScrollable
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: children,
                    ),
                  )
                : Row(children: children),
          ),
        ),
      ),
    );
  }
}
