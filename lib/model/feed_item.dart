class FeedItem {
  const FeedItem({required this.id, required this.name, required this.icon});

  final int id;
  final String name;
  final String icon;

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    return FeedItem(
      id: json['id'] as int,
      name: json['name'] as String,
      icon: json['icon'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'icon': icon};
  }
}
