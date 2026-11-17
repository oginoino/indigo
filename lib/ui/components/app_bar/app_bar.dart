import 'package:material_ui/material_ui.dart';
import '../avatar.dart';
import 'nav_bar.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    

    return SliverAppBar(
      title: Icon(Icons.star),
      actions: [
        IconButton(onPressed: () {}, icon: Icon(Icons.search)),
      ],
      leading: Avatar(),
      
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(40),
        child: NavBar(),),
    );
  }
}

  