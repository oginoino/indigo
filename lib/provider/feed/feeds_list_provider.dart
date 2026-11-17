import 'package:material_ui/material_ui.dart';

import '../../model/feed_item.dart';
import '../../service/feed/feeds_list_service.dart';

class FeedsListProvider extends ChangeNotifier {
  FeedsListProvider(this._feedsListService);

  final FeedsListService _feedsListService;

  List<FeedItem> _feedsList = [];
  FeedItem? _selectedFeed;
  bool _isLoading = false;
  Future<List<FeedItem>>? _pendingRequest;
  double _navBarScrollOffset = 0;

  List<FeedItem> get feedsList => List.unmodifiable(_feedsList);
  FeedItem? get selectedFeed => _selectedFeed;
  bool get isLoading => _isLoading;
  bool get hasFeeds => _feedsList.isNotEmpty;
  double get navBarScrollOffset => _navBarScrollOffset;

  void saveNavBarScrollOffset(double offset) {
    if (offset == _navBarScrollOffset) return;
    _navBarScrollOffset = offset;
  }

  Future<List<FeedItem>> getFeedsList() {
    final pendingRequest = _pendingRequest;
    if (pendingRequest != null) return pendingRequest;

    _isLoading = true;
    notifyListeners();

    final request = _loadFeeds();
    _pendingRequest = request;
    return request;
  }

  Future<List<FeedItem>> _loadFeeds() async {
    try {
      _feedsList = await _feedsListService.getFeedsList();
      _selectedFeed = _resolveSelectedFeed(_feedsList, _selectedFeed?.id);
      return _feedsList;
    } finally {
      _isLoading = false;
      _pendingRequest = null;
      notifyListeners();
    }
  }

  void selectFeed(int feedId) {
    if (_selectedFeed?.id == feedId) return;

    final feed = _feedsList.where((item) => item.id == feedId).firstOrNull;
    if (feed == null) return;

    _selectedFeed = feed;
    notifyListeners();
  }

  bool isFeedSelected(int feedId) => _selectedFeed?.id == feedId;

  static FeedItem? _resolveSelectedFeed(List<FeedItem> feeds, int? selectedId) {
    if (feeds.isEmpty) return null;

    return feeds.where((feed) => feed.id == selectedId).firstOrNull ??
        feeds.first;
  }
}
