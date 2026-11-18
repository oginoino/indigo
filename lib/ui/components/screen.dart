import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../provider/bottom_navigation_bar/bottom_navigation_bar_list.dart';
import '../../util/resolver/navigation_icon_resolver.dart';
import 'app_bar/app_bar.dart';
import 'custom_bottom_navigation_bar.dart';

class Screen extends StatelessWidget {
  const Screen({
    required this.child,
    this.appBar,
    this.bottomSliver,
    super.key,
  });

  final Widget child;
  final CustomAppBar? appBar;
  final Widget? bottomSliver;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: CustomScrollView(
        slivers: [
          appBar ?? const CustomAppBar(),
          SliverFillRemaining(child: child),
          ?bottomSliver,
        ],
      ),
      bottomNavigationBar: Consumer<BottomNavigationBarListProvider>(
        builder: (context, provider, _) {
          final navigationItems = provider.bottomNavigationBarList;

          if (navigationItems.isEmpty) {
            if (provider.isLoading) {
              return const SafeArea(
                top: false,
                child: SizedBox(
                  height: 72,
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            if (provider.error != null) {
              return SafeArea(
                top: false,
                child: SizedBox(
                  height: 72,
                  child: Center(
                    child: TextButton(
                      onPressed: provider.loadBottomNavigationBarList,
                      child: const Text('Tentar novamente'),
                    ),
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          }

          final items = navigationItems
              .map((item) {
                final icon = NavigationIconResolver.resolve(item.icon);

                return BottomNavigationBarItem(
                  icon: Icon(icon),
                  activeIcon: Icon(
                    NavigationIconResolver.resolveActive(item.icon),
                  ),
                  label: item.name,
                  tooltip: item.name,
                );
              })
              .toList(growable: false);

          final selectedItem = provider.selectedBottomNavigationItem;

          final index = selectedItem == null
              ? 0
              : navigationItems.indexWhere(
                  (item) => item.id == selectedItem.id,
                );

          return CustomBottomNavigationBar(
            items: items,
            currentIndex: index >= 0 ? index : 0,
            onTap: (index) {
              if (index < 0 || index >= navigationItems.length) {
                return;
              }

              provider.selectBottomNavigationItem(navigationItems[index]);
              context.go(navigationItems[index].route);
            },
          );
        },
      ),
    );
  }
}
