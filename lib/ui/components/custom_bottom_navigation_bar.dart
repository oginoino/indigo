
import 'dart:ui';

import 'package:material_ui/material_ui.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;

  static const double _height = 60;
  static const double _radius = 40;
  static const int _maxVisibleItems = 5;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final navTheme = theme.bottomNavigationBarTheme;

    final selectedColor =
        navTheme.selectedItemColor ?? colors.onSurface;

    final unselectedColor =
        navTheme.unselectedItemColor ?? colors.onSurface;

    final backgroundColor =
        navTheme.backgroundColor ?? colors.surface;

    final selectedIndex =
        currentIndex >= 0 && currentIndex < items.length
            ? currentIndex
            : -1;

    final isScrollable = items.length > _maxVisibleItems;

    final children = List<Widget>.generate(
      items.length,
      (index) {
        final item = items[index];
        final selected = index == selectedIndex;

        final configuredIconTheme = selected
            ? navTheme.selectedIconTheme
            : navTheme.unselectedIconTheme;

        final iconTheme = (configuredIconTheme ??
                theme.iconTheme)
            .copyWith(
          color: selected ? selectedColor : unselectedColor,
        );

        final button = Semantics(
          button: true,
          selected: selected,
          label: item.label,
          child: Tooltip(
            message: item.label ?? '',
            child: InkWell(
              onTap: () => onTap(index),
              borderRadius: BorderRadius.circular(_radius),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: selected
                      ? colors.onSurface.withValues(
                          alpha: theme.brightness == Brightness.dark
                              ? 0.16
                              : 0.07,
                        )
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(_radius),
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
            width: 64,
            child: button,
          );
        }

        return Expanded(
          key: ValueKey(index),
          child: button,
        );
      },
      growable: false,
    );

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 18,
            sigmaY: 18,
          ),
          child: Container(
            height: _height,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(_radius),
              border: Border.all(
                color: colors.outlineVariant.withValues(
                  alpha: 0.55,
                ),
              ),
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
