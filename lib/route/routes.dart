class RouteInfo {
  final String name;
  final String path;

  RouteInfo({required this.name, required this.path});
}

final List<RouteInfo> _routes = [
  RouteInfo(name: 'home', path: '/'),
];


class Routes {
  static final List<RouteInfo> routes = _routes;

  static List<String> get allRoutesNames => routes.map((e) => e.name).toList();
  
  static String get home => routes.firstWhere((e) => e.name == 'home').path;
}

