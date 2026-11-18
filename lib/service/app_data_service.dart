import 'dart:convert';

import 'package:flutter/services.dart';

import '../model/bottom_navigation_item.dart';
import '../model/feed_item.dart';

abstract interface class AppDataService {
  Future<void> load();

  List<FeedItem> get feeds;
  List<BottomNavigationItem> get bottomNavigationItems;
}

class AssetAppDataService implements AppDataService {
  AssetAppDataService();

  static const _assetPath = 'assets/data/app_data.json';

  List<FeedItem>? _feeds;
  List<BottomNavigationItem>? _bottomNavigationItems;
  Future<void>? _pendingLoad;

  @override
  List<FeedItem> get feeds => _feeds ?? _notLoaded();

  @override
  List<BottomNavigationItem> get bottomNavigationItems =>
      _bottomNavigationItems ?? _notLoaded();

  @override
  Future<void> load() {
    if (_feeds != null && _bottomNavigationItems != null) {
      return Future.value();
    }

    return _pendingLoad ??= _load();
  }

  Future<void> _load() async {
    try {
      final json = jsonDecode(await rootBundle.loadString(_assetPath));
      if (json is! Map<String, dynamic>) {
        throw const FormatException('App data must be a JSON object.');
      }

      final feeds = _readItems(json, 'feed_items', FeedItem.fromJson);
      final navigationItems = _readItems(
        json,
        'bottom_navigation_items',
        BottomNavigationItem.fromJson,
      );

      _feeds = List.unmodifiable(feeds);
      _bottomNavigationItems = List.unmodifiable(navigationItems);
    } finally {
      _pendingLoad = null;
    }
  }

  static List<T> _readItems<T>(
    Map<String, dynamic> data,
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final value = data[key];
    if (value is! List) {
      throw FormatException('App data is missing $key.');
    }

    return value
        .map((item) {
          if (item is! Map<String, dynamic>) {
            throw FormatException('Items in $key must be JSON objects.');
          }
          return fromJson(item);
        })
        .toList(growable: false);
  }

  Never _notLoaded() {
    throw StateError('App data has not been loaded yet.');
  }
}
