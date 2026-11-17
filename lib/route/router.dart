import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'routes.dart';
import 'handle_redirect.dart';
import 'app_route.dart';
import '../ui/page/home_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: Routes.home,
  redirect: HandleRedirect().handleRedirect,
  routes: [
    ShellRoute(
      builder: (context, state, child) => child,
      routes: [
      
         AppRoute(
          Routes.home,
          (context, state) => const HomePage(),
          padding: EdgeInsets.zero,
          hasScrollBody: true,
        ),
      ],
    ),
  ],
);