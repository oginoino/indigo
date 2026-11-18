import 'package:material_ui/material_ui.dart';

import '../../model/feed_item.dart';
import '../../util/const/ui/ui_constants.dart';

class FeedsListProvider extends ChangeNotifier {
  FeedsListProvider(List<FeedItem> feeds)
    : _feedsList = List.unmodifiable(feeds),
      _selectedFeed = feeds.firstOrNull;

  final List<FeedItem> _feedsList;
  FeedItem? _selectedFeed;
  double _navBarScrollOffset = UIConstants.navBarScrollInitialOffset;

  List<FeedItem> get feeds => _feedsList;
  FeedItem? get selectedFeed => _selectedFeed;
  double get navBarScrollOffset => _navBarScrollOffset;

  void saveNavBarScrollOffset(double offset) {
    if (offset == _navBarScrollOffset) return;
    _navBarScrollOffset = offset;
  }

  void selectFeed(int feedId) {
    if (_selectedFeed?.id == feedId) return;

    final feed = _feedsList.where((item) => item.id == feedId).firstOrNull;
    if (feed == null) return;

    _selectedFeed = feed;
    notifyListeners();
  }

  bool isFeedSelected(int feedId) => _selectedFeed?.id == feedId;
}
