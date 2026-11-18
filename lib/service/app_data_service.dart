import 'dart:convert';

import 'package:flutter/services.dart';

import '../model/bottom_navigation_item.dart';
import '../model/feed_item.dart';
import '../util/const/app/app_data_constants.dart';
import '../util/const/app/app_strings.dart';

abstract interface class AppDataService {
  Future<void> load();

  List<FeedItem> get feeds;
  List<BottomNavigationItem> get bottomNavigationItems;
}

class AssetAppDataService implements AppDataService {
  AssetAppDataService();

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
      return Future<void>.value();
    }

    return _pendingLoad ??= _load();
  }

  Future<void> _load() async {
    try {
      final json = jsonDecode(
        await rootBundle.loadString(AppDataConstants.assetPath),
      );
      if (json is! Map<String, dynamic>) {
        throw const FormatException(AppStrings.invalidAppData);
      }

      final feeds = _readItems(
        json,
        AppDataConstants.feedItemsKey,
        FeedItem.fromJson,
      );
      final navigationItems = _readItems(
        json,
        AppDataConstants.bottomNavigationItemsKey,
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
      throw FormatException(
        AppStrings.missingAppDataSection.replaceAll('{section}', key),
      );
    }

    return value
        .map((item) {
          if (item is! Map<String, dynamic>) {
            throw FormatException(
              AppStrings.invalidAppDataItems.replaceAll('{section}', key),
            );
          }
          return fromJson(item);
        })
        .toList(growable: false);
  }

  Never _notLoaded() {
    throw StateError(AppStrings.appDataNotLoaded);
  }
}
