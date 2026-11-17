import 'dart:convert';
import 'package:flutter/services.dart';
import '../../model/feed_item.dart';

class FeedsListService {
  static Future<List<FeedItem>> getFeedsList() async {
    final appData = await rootBundle.loadString('assets/data/app_data.json');
    final data = jsonDecode(appData);
    return (data['feed_items'] as List<dynamic>).map((item) => FeedItem.fromJson(item as Map<String, dynamic>)).toList();
  }
}

