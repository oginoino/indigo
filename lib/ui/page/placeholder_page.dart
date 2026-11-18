import 'package:material_ui/material_ui.dart';

import '../components/screen.dart';

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({required this.title, this.appBar, super.key});

  final String title;
  final Widget? appBar;

  @override
  Widget build(BuildContext context) {
    return Screen(
      appBar: appBar,
      child: Center(child: Text(title)),
    );
  }
}
