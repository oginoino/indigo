

import 'package:material_ui/material_ui.dart';

import '../../model/bottom_navigation_item.dart';
import '../../service/bottom_navigation_bar/bottom_navigation_bar_list_service.dart' show BottomNavigationBarListService;

class BottomNavigationBarListProvider extends ChangeNotifier {
  BottomNavigationBarListProvider(this._bottomNavigationBarListService);

  
  final BottomNavigationBarListService _bottomNavigationBarListService;

  List<BottomNavigationItem> _bottomNavigationBarList = [];
  bool _isLoading = false;
  Future<List<BottomNavigationItem>>? _pendingRequest;
  BottomNavigationItem? _selectedBottomNavigationItem;

  List<BottomNavigationItem> get bottomNavigationBarList => List.unmodifiable(_bottomNavigationBarList);
  bool get isLoading => _isLoading;
  bool get hasBottomNavigationBarItems => _bottomNavigationBarList.isNotEmpty;
  BottomNavigationItem? get selectedBottomNavigationItem => _selectedBottomNavigationItem;

  void loadBottomNavigationBarList() async {
    _isLoading = true;
    notifyListeners();
    _pendingRequest ??= _bottomNavigationBarListService.getBottomNavigationBarItems();
    _bottomNavigationBarList = await _pendingRequest!;
    _isLoading = false;
    notifyListeners();
  }

  void selectBottomNavigationItem(BottomNavigationItem item) {
    if (item == _selectedBottomNavigationItem) return;
    _selectedBottomNavigationItem = item;
    notifyListeners();
  }
}