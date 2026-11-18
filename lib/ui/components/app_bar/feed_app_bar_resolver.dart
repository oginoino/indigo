import 'package:material_ui/material_ui.dart';

import '../../../util/const/app/app_data_constants.dart';
import '../../../util/const/app/app_strings.dart';
import 'app_bar.dart';

class FeedAppBarResolver {
  const FeedAppBarResolver._();

  static Widget? resolve(String? appBar, String title) {
    return switch (appBar) {
      null || AppDataConstants.noAppBarType => null,
      AppDataConstants.feedAppBarType => const CustomAppBar(),
      AppDataConstants.compactAppBarType => SliverAppBar(title: Text(title)),
      _ => throw FormatException(
        AppStrings.unknownFeedAppBar.replaceAll('{appBar}', appBar),
      ),
    };
  }
}
