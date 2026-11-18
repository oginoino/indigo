import 'package:material_ui/material_ui.dart';

import '../../model/bottom_navigation_item.dart';

class BottomNavigationProvider extends ChangeNotifier {
  BottomNavigationProvider(List<BottomNavigationItem> items)
    : _items = List.unmodifiable(items),
      _selectedItem = items.firstOrNull;

  final List<BottomNavigationItem> _items;
  BottomNavigationItem? _selectedItem;

  List<BottomNavigationItem> get items => _items;
  BottomNavigationItem? get selectedItem => _selectedItem;

  void selectItem(BottomNavigationItem item) {
    final index = _items.indexWhere((candidate) => candidate.id == item.id);

    if (index == -1) return;

    if (_selectedItem?.id == item.id) return;

    _selectedItem = _items[index];

    notifyListeners();
  }
}
