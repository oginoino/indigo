
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final navTheme = theme.bottomNavigationBarTheme;

    final selectedColor =
        navTheme.selectedItemColor ?? colors.onSurface;
    final unselectedColor =
        navTheme.unselectedItemColor ?? colors.onSurface;
    final backgroundColor =
        navTheme.backgroundColor ?? colors.surface;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: 60,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: colors.outlineVariant.withValues(
                  alpha: 0.55,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(items.length, (index) {
                final item = items[index];
                final selected = index == currentIndex;
                final iconTheme = selected
                    ? navTheme.selectedIconTheme
                    : navTheme.unselectedIconTheme;

                return Expanded(
                  child: Semantics(
                    button: true,
                    selected: selected,
                    label: item.label,
                    child: InkWell(
                      onTap: () => onTap(index),
                      borderRadius: BorderRadius.circular(35),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        decoration: BoxDecoration(
                          color: selected
                              ? colors.onSurface.withValues(
                                  alpha: 0.08,
                                )
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(35),
                        ),
                        child: Center(
                          child: IconTheme(
                            data: (iconTheme ?? const IconThemeData())
                                .copyWith(
                              color: selected
                                  ? selectedColor
                                  : unselectedColor,
                            ),
                            child: selected
                                ? item.activeIcon
                                : item.icon,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
