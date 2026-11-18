
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
            icon: Icon(Icons.video_library_rounded),
            label: 'Videos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline_rounded),
            label: 'Criar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.send_rounded), label: 'Mensagens'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Perfil'),
        ],
      ),
    );
  }
}
