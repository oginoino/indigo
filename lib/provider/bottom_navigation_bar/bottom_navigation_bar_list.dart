
import 'package:material_ui/material_ui.dart';

import '../../model/bottom_navigation_item.dart';
import '../../service/bottom_navigation_bar/bottom_navigation_bar_list_service.dart';

class BottomNavigationBarListProvider extends ChangeNotifier {
  BottomNavigationBarListProvider(
    this._bottomNavigationBarListService,
  );

  final BottomNavigationBarListService
      _bottomNavigationBarListService;

  List<BottomNavigationItem> _bottomNavigationBarList = [];

  BottomNavigationItem? _selectedBottomNavigationItem;

  bool _isLoading = false;
  bool _disposed = false;

  Future<List<BottomNavigationItem>>? _pendingRequest;

  List<BottomNavigationItem> get bottomNavigationBarList =>
      List.unmodifiable(_bottomNavigationBarList);

  bool get isLoading => _isLoading;

  bool get hasBottomNavigationBarItems =>
      _bottomNavigationBarList.isNotEmpty;

  BottomNavigationItem? get selectedBottomNavigationItem =>
      _selectedBottomNavigationItem;

  Future<void> loadBottomNavigationBarList() async {
    // Reutiliza uma requisição que já esteja em andamento.
    final pending = _pendingRequest;

    if (pending != null) {
      try {
        await pending;
      } catch (_) {
        // O erro é tratado pela chamada que iniciou a requisição.
      }
      return;
    }

    if (_disposed) return;

    _isLoading = true;
    notifyListeners();

    final request =
        _bottomNavigationBarListService.getBottomNavigationBarItems();

    _pendingRequest = request;

    try {
      debugPrint('[BottomNavigation] Iniciando carregamento');

      final items = await request;

      if (_disposed) return;

      _bottomNavigationBarList = items;

      final selectedId = _selectedBottomNavigationItem?.id;

      BottomNavigationItem? nextSelection;

      if (selectedId != null) {
        for (final item in items) {
          if (item.id == selectedId) {
            nextSelection = item;
            break;
          }
        }
      }

      _selectedBottomNavigationItem =
          nextSelection ?? (items.isNotEmpty ? items.first : null);

      debugPrint(
        '[BottomNavigation] Carregamento concluído: '
        '${items.length} itens',
      );
    } catch (error, stackTrace) {
      debugPrint('[BottomNavigation] Erro: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (identical(_pendingRequest, request)) {
        _pendingRequest = null;
      }

      if (!_disposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void selectBottomNavigationItem(BottomNavigationItem item) {
    if (_disposed) return;

    final index = _bottomNavigationBarList.indexWhere(
      (element) => element.id == item.id,
    );

    if (index == -1) return;

    if (_selectedBottomNavigationItem?.id == item.id) return;

    _selectedBottomNavigationItem = _bottomNavigationBarList[index];

    notifyListeners();
  }

  void clearBottomNavigationBarList() {
    if (_disposed) return;

    _bottomNavigationBarList = [];
    _selectedBottomNavigationItem = null;

    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
