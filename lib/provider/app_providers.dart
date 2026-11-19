import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../di/di.dart';
import '../service/persistence/avatar_image_service.dart';
import '../service/mapper/hashtag_json_mapper.dart';
import '../service/social_data_service.dart';
import 'bottom_navigation_bar/bottom_navigation_provider.dart';
import 'feed/feeds_list_provider.dart';
import 'post/posts_provider.dart';
import 'theme/theme_provider.dart';

List<SingleChildWidget> get appProviders => [
  Provider<AvatarImageService>.value(value: avatarImageService),
  Provider<SocialDataService>.value(value: socialDataService),
  ChangeNotifierProvider(create: (_) => ThemeProvider(persistenceService)),
  ChangeNotifierProvider(
    create: (_) => FeedsListProvider(
      appDataService.feeds,
      hashtags: socialDataService.data.hashtags
          .map(HashtagJsonMapper.fromJson)
          .toList(growable: false),
      persistenceService: persistenceService,
    ),
  ),
  ChangeNotifierProvider(
    create: (_) =>
        BottomNavigationProvider(appDataService.bottomNavigationItems),
  ),
  ChangeNotifierProvider(
    create: (_) => PostsProvider(
      repository: postRepository,
      socialDataService: socialDataService,
    )..load(),
  ),
];
