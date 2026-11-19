import '../util/const/app/app_data_constants.dart';
import 'hashtag.dart';

class FeedItem {
  const FeedItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.route,
    this.appBar,
    this.hashtag,
  });

  final int id;
  final String name;
  final String icon;
  final String route;
  final String? appBar;
  final Hashtag? hashtag;

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    return FeedItem(
      id: json[AppDataConstants.idKey] as int,
      name: json[AppDataConstants.nameKey] as String,
      icon: json[AppDataConstants.iconKey] as String,
      route: json[AppDataConstants.routeKey] as String,
      appBar: json[AppDataConstants.appBarKey] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      AppDataConstants.idKey: id,
      AppDataConstants.nameKey: name,
      AppDataConstants.iconKey: icon,
      AppDataConstants.routeKey: route,
      AppDataConstants.appBarKey: appBar,
    };
  }
}
