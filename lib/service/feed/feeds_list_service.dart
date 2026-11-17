import 'dart:convert';

import 'package:flutter/services.dart';

import '../../model/feed_item.dart';

class FeedsListService {
  const FeedsListService();

  static const _assetPath = 'assets/data/app_data.json';

  Future<List<FeedItem>> getFeedsList() async {
    final appData = await rootBundle.loadString(_assetPath);
    final data = jsonDecode(appData);
    if (data is! Map<String, dynamic>) {
      throw const FormatException('App data must be a JSON object.');
    }

    final items = data['feed_items'];
    if (items is! List<dynamic>) {
      throw const FormatException('App data is missing feed items.');
    }

    return items
        .map((item) => FeedItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
