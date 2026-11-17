import 'package:material_ui/material_ui.dart';

import 'app_bar/app_bar.dart';

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
    final bottom = bottomSliver;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          appBar ?? const CustomAppBar(),
          SliverFillRemaining(child: child),
          ?bottom,
        ],
      ),
    );
  }
}
