import 'package:material_ui/material_ui.dart';
import '../components/screen.dart';
import '../../util/const/app/app_constants.dart';
import '../components/app_bar/app_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Screen(
      appBar: CustomAppBar(),
      child: Center(child: Text(AppConstants.appName)),
    );
  }
}