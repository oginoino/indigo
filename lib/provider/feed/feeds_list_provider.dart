
import 'package:material_ui/material_ui.dart';

import '../../service/feed/feeds_list_service.dart';
import '../../model/feed_item.dart';

class FeedsListProvider extends ChangeNotifier {
  List<FeedItem> _feedsList = [];
  FeedItem? _selectedFeed;
  bool _isLoading = false;
  Future<List<FeedItem>>? _pendingRequest;

  List<FeedItem> get feedsList => List.unmodifiable(_feedsList);
  FeedItem? get selectedFeed => _selectedFeed;
  bool get isLoading => _isLoading;
  bool get hasFeeds => _feedsList.isNotEmpty;

  double _navBarScrollOffset = 0.0;

  double get navBarScrollOffset => _navBarScrollOffset;

void saveNavBarScrollOffset(double offset) {
  if (offset == _navBarScrollOffset) return;

  _navBarScrollOffset = offset;
}

  Future<List<FeedItem>> getFeedsList() {
    // Reaproveita uma requisição em andamento.
    if (_pendingRequest != null) return _pendingRequest!;

    _isLoading = true;
    notifyListeners();

    final request = _loadFeeds();
    _pendingRequest = request;
    return request;
  }

  Future<List<FeedItem>> _loadFeeds() async {
    try {
      _feedsList = await FeedsListService.getFeedsList();

      if (_feedsList.isNotEmpty) {
        final selectedId = _selectedFeed?.id.toString();

        _selectedFeed = selectedId == null
            ? _feedsList.first
            : _feedsList.cast<FeedItem?>().firstWhere(
                  (feed) => feed?.id.toString() == selectedId,
                  orElse: () => _feedsList.first,
                );
      } else {
        _selectedFeed = null;
      }

      return _feedsList;
    } finally {
      _isLoading = false;
      _pendingRequest = null;
      notifyListeners();
    }
  }

  void selectFeed(String itemId) {
    for (final feed in _feedsList) {
      if (feed.id.toString() == itemId) {
        if (_selectedFeed?.id.toString() == itemId) return;

        _selectedFeed = feed;
        notifyListeners();
        return;
      }
    }
  }

  bool isFeedSelected(String itemId) {
    return _selectedFeed?.id.toString() == itemId;
  }

  FeedItem getSelectedFeed() {
    if (_selectedFeed != null) return _selectedFeed!;

    if (_feedsList.isNotEmpty) {
      _selectedFeed = _feedsList.first;
      return _selectedFeed!;
    }

    throw StateError('A lista de feeds ainda não foi carregada.');
  }
}
