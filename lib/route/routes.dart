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
  static const String discover = '/discover';
  static const String friends = '/friends';
  static const String communities = '/communities';
  static const String news = '/news';
  static const String appbarVideos = '/appbar-videos';
  static const String photos = '/photos';
  static const String events = '/events';

  static const List<RouteInfo> routes = [
    RouteInfo(name: 'home', path: home),
    RouteInfo(name: 'videos', path: videos),
    RouteInfo(name: 'create', path: create),
    RouteInfo(name: 'messages', path: messages),
    RouteInfo(name: 'profile', path: profile),
    RouteInfo(name: 'discover', path: discover),
    RouteInfo(name: 'friends', path: friends),
    RouteInfo(name: 'communities', path: communities),
    RouteInfo(name: 'news', path: news),
    RouteInfo(name: 'appbar_videos', path: appbarVideos),
    RouteInfo(name: 'photos', path: photos),
    RouteInfo(name: 'events', path: events),
  ];

  static List<String> get allRouteNames =>
      routes.map((route) => route.name).toList();
}
