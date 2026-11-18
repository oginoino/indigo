import 'package:go_router/go_router.dart';

import '../di/di.dart';
import '../ui/components/app_bar/app_bar.dart';
import '../ui/components/app_bar/feed_app_bar_resolver.dart';
import '../ui/page/home_page.dart';
import '../ui/page/placeholder_page.dart';
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
    if (!feed.route.startsWith('/') || !registeredPaths.add(feed.route)) {
      throw FormatException('Invalid or duplicate feed route: ${feed.route}');
    }

    return AppRoute(
      feed.route,
      (context, state) => PlaceholderPage(
        title: feed.name,
        appBar: FeedAppBarResolver.resolve(feed.appBar, feed.name),
      ),
    );
  });

  return [
    AppRoute(Routes.home, (context, state) => const HomePage()),
    AppRoute(
      Routes.videos,
      (context, state) =>
          const PlaceholderPage(title: 'Vídeos', appBar: CustomAppBar()),
    ),
    AppRoute(
      Routes.create,
      (context, state) =>
          const PlaceholderPage(title: 'Criar', appBar: CustomAppBar()),
    ),
    AppRoute(
      Routes.messages,
      (context, state) =>
          const PlaceholderPage(title: 'Mensagens', appBar: CustomAppBar()),
    ),
    AppRoute(
      Routes.profile,
      (context, state) =>
          const PlaceholderPage(title: 'Perfil', appBar: CustomAppBar()),
    ),
    ...feedRoutes,
  ];
}
