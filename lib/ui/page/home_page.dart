import 'package:material_ui/material_ui.dart';

import '../../util/const/app/app_constants.dart';
import '../components/app_bar/app_bar.dart';
import '../components/screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Screen(
      appBar: CustomAppBar(),
      child: Center(child: Text(AppConstants.appName)),
    );
  }
}
