import 'package:go_router/go_router.dart';

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

final List<GoRoute> _routes = [
  AppRoute(Routes.home, (context, state) => const HomePage()),
  AppRoute(
    Routes.videos,
    (context, state) => const PlaceholderPage(title: 'Vídeos'),
  ),
  AppRoute(
    Routes.create,
    (context, state) => const PlaceholderPage(title: 'Criar'),
  ),
  AppRoute(
    Routes.messages,
    (context, state) => const PlaceholderPage(title: 'Mensagens'),
  ),
  AppRoute(
    Routes.profile,
    (context, state) => const PlaceholderPage(title: 'Perfil'),
  ),
  AppRoute(
    Routes.discover,
    (context, state) => const PlaceholderPage(title: 'Descobrir'),
  ),
  AppRoute(
    Routes.friends,
    (context, state) => const PlaceholderPage(title: 'Amigos'),
  ),
  AppRoute(
    Routes.communities,
    (context, state) => const PlaceholderPage(title: 'Comunidades'),
  ),
  AppRoute(
    Routes.news,
    (context, state) => const PlaceholderPage(title: 'Notícias'),
  ),
  AppRoute(
    Routes.appbarVideos,
    (context, state) => const PlaceholderPage(title: 'Vídeos'),
  ),
  AppRoute(
    Routes.photos,
    (context, state) => const PlaceholderPage(title: 'Fotos'),
  ),
  AppRoute(
    Routes.events,
    (context, state) => const PlaceholderPage(title: 'Eventos'),
  ),
];
