class BottomNavigationItem {
  const BottomNavigationItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.route,
  });

  final int id;
  final String name;
  final String icon;
  final String route;

  factory BottomNavigationItem.fromJson(Map<String, dynamic> json) {
    return BottomNavigationItem(
      id: json['id'] as int,
      name: json['name'] as String,
      icon: json['icon'] as String,
      route: json['route'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'icon': icon, 'route': route};
  }
}
