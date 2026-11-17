import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../di/di.dart';
import 'feed/feeds_list_provider.dart';
import 'theme/theme_provider.dart';

List<SingleChildWidget> get appProviders => [
  ChangeNotifierProvider(create: (_) => ThemeProvider(persistenceService)),
  ChangeNotifierProvider(create: (_) => FeedsListProvider(feedsListService)),
];
