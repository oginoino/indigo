import 'package:material_ui/material_ui.dart';

import 'app_bar.dart';

class FeedAppBarResolver {
  const FeedAppBarResolver._();

  static Widget? resolve(String? appBar, String title) {
    return switch (appBar) {
      null || 'none' => null,
      'feed' => const CustomAppBar(),
      'compact' => SliverAppBar(title: Text(title)),
      _ => throw FormatException('Unknown feed app bar: $appBar'),
    };
  }
}
