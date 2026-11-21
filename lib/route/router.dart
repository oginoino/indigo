import 'package:go_router/go_router.dart';

import '../di/di.dart';
import '../ui/components/app_bar/app_bar.dart';
import '../ui/page/create_page.dart';
import '../ui/page/feed_page.dart';
import '../ui/page/hashtag_feed_page.dart';
import '../ui/page/home_page.dart';
import '../ui/page/placeholder_page.dart';
import '../ui/page/videos_page.dart';
import '../util/const/app/app_strings.dart';
import 'app_route.dart';
import 'handle_redirect.dart';
import 'routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: Routes.home,
  redirect: HandleRedirect().handleRedirect,
  routes: _routes,
);

final List<GoRoute> _routes = _buildRoutes();

List<GoRoute> _buildRoutes() {
  final registeredPaths = Routes.routes.map((route) => route.path).toSet();

  final feedRoutes = appDataService.feeds.map((feed) {
    if (!feed.route.startsWith(Routes.pathSeparator) ||
        !registeredPaths.add(feed.route)) {
      throw FormatException(
        AppStrings.invalidOrDuplicateFeedRoute.replaceAll(
          '{route}',
          feed.route,
        ),
      );
    }

    return AppRoute(feed.route, (context, state) => FeedPage(feed: feed));
  });

  return [
    AppRoute(Routes.home, (context, state) => const HomePage()),
    AppRoute(
      Routes.videos,
      (context, state) => VideosPage(
        initialPostId:
            state.uri.queryParameters[Routes.videoPostIdQueryParameter],
        initialMediaId:
            state.uri.queryParameters[Routes.videoMediaIdQueryParameter],
      ),
    ),
    AppRoute(
      Routes.hashtags,
      (context, state) =>
          HashtagFeedPage(hashtagId: state.pathParameters['hashtagId']!),
    ),
    AppRoute(Routes.create, (context, state) => const CreatePage()),
    AppRoute(
      Routes.messages,
      (context, state) => const PlaceholderPage(
        title: AppStrings.messagesTitle,
        appBar: CustomAppBar(),
      ),
    ),
    AppRoute(
      Routes.profile,
      (context, state) => const PlaceholderPage(
        title: AppStrings.profileTitle,
        appBar: CustomAppBar(),
      ),
    ),
    ...feedRoutes,
  ];
}
