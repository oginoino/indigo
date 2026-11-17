import 'package:material_ui/material_ui.dart';
import 'app_bar/app_bar.dart';

class Screen extends StatelessWidget {

  final Widget child;
  final CustomAppBar? appBar;
  final SliverToBoxAdapter? bottomNavigationBar;
  
  const Screen({
    required this.child,
    this.appBar,
    this.bottomNavigationBar,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
      slivers: [
        appBar ?? CustomAppBar(),
        SliverFillRemaining(
          child: child,
        ),
        bottomNavigationBar ?? SliverToBoxAdapter(),

      ],
    ),
    );
  }
}