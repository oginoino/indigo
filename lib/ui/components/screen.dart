import 'package:material_ui/material_ui.dart';

import 'app_bottom_navigation_bar.dart';

class Screen extends StatelessWidget {
  const Screen({
    this.child,
    this.slivers,
    this.appBar,
    this.bottomSliver,
    this.onRefresh,
    super.key,
  }) : assert(child != null || slivers != null);

  final Widget? child;
  final List<Widget>? slivers;
  final Widget? appBar;
  final Widget? bottomSliver;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final scrollView = CustomScrollView(
      physics: onRefresh == null ? null : const AlwaysScrollableScrollPhysics(),
      slivers: [
        ?appBar,
        if (slivers case final contentSlivers?)
          ...contentSlivers
        else
          SliverFillRemaining(child: child!),
        ?bottomSliver,
      ],
    );

    return Scaffold(
      extendBody: true,
      body: onRefresh == null
          ? scrollView
          : RefreshIndicator(onRefresh: onRefresh!, child: scrollView),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}
