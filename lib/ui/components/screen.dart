
import 'package:material_ui/material_ui.dart';

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
      body: CustomScrollView(
        slivers: [
          appBar ?? const CustomAppBar(),
          SliverFillRemaining(child: child),
          if (bottomSliver != null) bottomSliver!,
        ],
      ),
      extendBody: true,
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {},
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_rounded),
            label: 'Notifications',
          ),

        ],
      ),
    );
  }
}
