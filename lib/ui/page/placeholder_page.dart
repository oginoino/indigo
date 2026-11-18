import 'package:material_ui/material_ui.dart';

import '../components/app_bar/app_bar.dart';
import '../components/screen.dart';

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Screen(
      appBar: const CustomAppBar(),
      child: Center(child: Text(title)),
    );
  }
}
