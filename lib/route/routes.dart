class RouteInfo {
  const RouteInfo({required this.name, required this.path});

  final String name;
  final String path;
}

class Routes {
  const Routes._();

  static const String home = '/';
  static const String videos = '/videos';
  static const String create = '/create';
  static const String messages = '/messages';
  static const String profile = '/profile';

  static const List<RouteInfo> routes = [
    RouteInfo(name: 'home', path: home),
    RouteInfo(name: 'videos', path: videos),
    RouteInfo(name: 'create', path: create),
    RouteInfo(name: 'messages', path: messages),
    RouteInfo(name: 'profile', path: profile),
  ];

  static List<String> get allRouteNames =>
      routes.map((route) => route.name).toList();
}
