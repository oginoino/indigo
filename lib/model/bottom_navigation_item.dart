import '../util/const/app/app_data_constants.dart';

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
      id: json[AppDataConstants.idKey] as int,
      name: json[AppDataConstants.nameKey] as String,
      icon: json[AppDataConstants.iconKey] as String,
      route: json[AppDataConstants.routeKey] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      AppDataConstants.idKey: id,
      AppDataConstants.nameKey: name,
      AppDataConstants.iconKey: icon,
      AppDataConstants.routeKey: route,
    };
  }
}
