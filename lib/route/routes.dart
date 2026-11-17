class RouteInfo {
  const RouteInfo({required this.name, required this.path});

  final String name;
  final String path;
}

class Routes {
  const Routes._();

  static const String home = '/';

  static const List<RouteInfo> routes = [RouteInfo(name: 'home', path: home)];

  static List<String> get allRouteNames =>
      routes.map((route) => route.name).toList();
}
