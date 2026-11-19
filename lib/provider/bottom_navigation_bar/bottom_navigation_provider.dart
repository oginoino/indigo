import 'package:material_ui/material_ui.dart';

import '../../model/bottom_navigation_item.dart';

class BottomNavigationProvider extends ChangeNotifier {
  BottomNavigationProvider(List<BottomNavigationItem> items)
    : _items = List.unmodifiable(items),
      _selectedItem = items.firstOrNull;

  final List<BottomNavigationItem> _items;
  BottomNavigationItem? _selectedItem;
  bool _isCompact = false;

  List<BottomNavigationItem> get items => _items;
  BottomNavigationItem? get selectedItem => _selectedItem;
  bool get isCompact => _isCompact;

  void selectItem(BottomNavigationItem item) {
    final index = _items.indexWhere((candidate) => candidate.id == item.id);

    if (index == -1) return;

    final selectionChanged = _selectedItem?.id != item.id;
    if (!selectionChanged && !_isCompact) return;

    _selectedItem = _items[index];
    _isCompact = false;

    notifyListeners();
  }

  void setCompact(bool isCompact) {
    if (_isCompact == isCompact) return;

    _isCompact = isCompact;
    notifyListeners();
  }
}
