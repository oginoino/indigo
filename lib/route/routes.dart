class RouteInfo {
  const RouteInfo({required this.name, required this.path});

  final String name;
  final String path;
}

class RouteNames {
  const RouteNames._();

  static const home = 'home';
  static const videos = 'videos';
  static const create = 'create';
  static const messages = 'messages';
  static const profile = 'profile';
}

class Routes {
  const Routes._();

  static const String pathSeparator = '/';
  static const String home = '/';
  static const String videos = '/videos';
  static const String create = '/create';
  static const String messages = '/messages';
  static const String profile = '/profile';

  static const List<RouteInfo> routes = [
    RouteInfo(name: RouteNames.home, path: home),
    RouteInfo(name: RouteNames.videos, path: videos),
    RouteInfo(name: RouteNames.create, path: create),
    RouteInfo(name: RouteNames.messages, path: messages),
    RouteInfo(name: RouteNames.profile, path: profile),
  ];

  static List<String> get allRouteNames =>
      routes.map((route) => route.name).toList();
}
