import 'dart:convert';

import 'package:flutter/services.dart';

import '../../model/bottom_navigation_item.dart';

abstract interface class BottomNavigationBarListService {
  Future<List<BottomNavigationItem>> getBottomNavigationBarItems();
}

class AppBottomNavigationBarListService
    implements BottomNavigationBarListService {
  const AppBottomNavigationBarListService();

  static const _assetPath = 'assets/data/app_data.json';

  @override
  Future<List<BottomNavigationItem>> getBottomNavigationBarItems() async {
    final appData = await rootBundle.loadString(_assetPath);
    final data = jsonDecode(appData);
    if (data is! Map<String, dynamic>) {
      throw const FormatException('App data must be a JSON object.');
    }

    final items = data['bottom_navigation_items'];
    if (items is! List<dynamic>) {
      throw const FormatException(
        'App data is missing bottom navigation items.',
      );
    }

    return items
        .map(
          (item) => BottomNavigationItem.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }
}
