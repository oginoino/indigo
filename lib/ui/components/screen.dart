import 'package:material_ui/material_ui.dart';

import 'app_bottom_navigation_bar.dart';

class Screen extends StatelessWidget {
  const Screen({
    required this.child,
    this.appBar,
    this.bottomSliver,
    super.key,
  });

  final Widget child;
  final Widget? appBar;
  final Widget? bottomSliver;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: CustomScrollView(
        slivers: [
          ?appBar,
          SliverFillRemaining(child: child),
          ?bottomSliver,
        ],
      ),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}
