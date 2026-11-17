import 'package:material_ui/material_ui.dart';

import '../../../util/const/ui/ui_constants.dart';
import '../avatar.dart';
import 'nav_bar.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: const Icon(Icons.star),
      leading: const Avatar(),
      actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(UIConstants.navBarHeight),
        child: NavBar(),
      ),
    );
  }
}
