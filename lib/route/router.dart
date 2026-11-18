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
];
