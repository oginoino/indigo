import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'routes.dart';

class HandleRedirect {
  String? _initialDeepLink;

  String? get initialDeepLink => _initialDeepLink;

  static const Set<String> publicRoutes = {Routes.home};

  static const Set<String> protectedRoutes = {};

  bool isProtectedRoute(String route) => protectedRoutes.contains(route);

  String? handleRedirect(BuildContext context, GoRouterState state) {
    _initialDeepLink = state.uri.toString();
    final path = state.uri.path;

    if (publicRoutes.contains(path) || !isProtectedRoute(path)) {
      return null;
    }

    return Routes.home;
  }
}
