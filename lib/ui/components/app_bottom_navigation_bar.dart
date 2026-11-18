import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../provider/bottom_navigation_bar/bottom_navigation_provider.dart';
import '../../util/resolver/navigation_icon_resolver.dart';
import 'custom_bottom_navigation_bar.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BottomNavigationProvider>(
      builder: (context, provider, _) {
        final items = provider.items;
        if (items.isEmpty) return const SizedBox.shrink();

        final selectedId = provider.selectedItem?.id;
        final selectedIndex = items.indexWhere((item) => item.id == selectedId);

        return CustomBottomNavigationBar(
          items: items
              .map(
                (item) => BottomNavigationBarItem(
                  icon: Icon(NavigationIconResolver.resolve(item.icon)),
                  activeIcon: Icon(
                    NavigationIconResolver.resolveActive(item.icon),
                  ),
                  label: item.name,
                  tooltip: item.name,
                ),
              )
              .toList(growable: false),
          currentIndex: selectedIndex < 0 ? 0 : selectedIndex,
          onTap: (index) {
            if (index < 0 || index >= items.length) return;

            final item = items[index];
            provider.selectItem(item);
            context.go(item.route);
          },
        );
      },
    );
  }
}
