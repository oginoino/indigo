class FeedItem {
  const FeedItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.route,
    this.appBar,
  });

  final int id;
  final String name;
  final String icon;
  final String route;
  final String? appBar;

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    return FeedItem(
      id: json['id'] as int,
      name: json['name'] as String,
      icon: json['icon'] as String,
      route: json['route'] as String,
      appBar: json['app_bar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'route': route,
      'app_bar': appBar,
    };
  }
}
