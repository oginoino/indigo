import 'dart:convert';

import 'package:flutter/services.dart';

import '../../model/feed_item.dart';

class FeedsListService {
  FeedsListService();

  static const _assetPath = 'assets/data/app_data.json';

  List<FeedItem>? _cachedFeeds;
  Future<List<FeedItem>>? _pendingRequest;

  List<FeedItem> get configuredFeeds {
    final feeds = _cachedFeeds;
    if (feeds == null) {
      throw StateError('Feed routes have not been loaded yet.');
    }
    return List.unmodifiable(feeds);
  }

  Future<List<FeedItem>> getFeedsList() {
    final cachedFeeds = _cachedFeeds;
    if (cachedFeeds != null) {
      return Future.value(List.unmodifiable(cachedFeeds));
    }

    return _pendingRequest ??= _loadFeedsList();
  }

  Future<List<FeedItem>> _loadFeedsList() async {
    try {
      final appData = await rootBundle.loadString(_assetPath);
      final data = jsonDecode(appData);
      if (data is! Map<String, dynamic>) {
        throw const FormatException('App data must be a JSON object.');
      }

      final items = data['feed_items'];
      if (items is! List<dynamic>) {
        throw const FormatException('App data is missing feed items.');
      }

      final feeds = items
          .map((item) => FeedItem.fromJson(item as Map<String, dynamic>))
          .toList();
      _cachedFeeds = List.unmodifiable(feeds);
      return _cachedFeeds!;
    } finally {
      _pendingRequest = null;
    }
  }
}
