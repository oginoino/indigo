import 'package:material_ui/material_ui.dart';

import '../../../util/const/ui/ui_constants.dart';
import '../avatar.dart';
import 'nav_bar.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({this.floating = false, this.snap = false, super.key});

  final bool floating;
  final bool snap;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: floating,
      snap: snap,
      title: const Icon(Icons.star),
      leadingWidth: UIConstants.appBarLeadingWidth,
      toolbarHeight: UIConstants.appBarToolbarHeight,
      leading: const Center(child: Avatar(size: AvatarSize.small)),
      actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(UIConstants.navBarHeight),
        child: NavBar(),
      ),
    );
  }
}
