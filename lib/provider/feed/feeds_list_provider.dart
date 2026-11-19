import 'package:material_ui/material_ui.dart';

import '../../model/feed_item.dart';
import '../../model/hashtag.dart';
import '../../service/persistence/persistence_service.dart';
import '../../util/const/ui/ui_constants.dart';

class FeedsListProvider extends ChangeNotifier {
  FeedsListProvider(
    List<FeedItem> feeds, {
    List<Hashtag> hashtags = const [],
    PersistenceService? persistenceService,
  }) : _feedsList = List.of(feeds),
       _hashtags = {for (final hashtag in hashtags) hashtag.id: hashtag},
       _persistenceService = persistenceService,
       _selectedFeed = feeds.firstOrNull {
    _nextFeedId =
        feeds.fold<int>(
          0,
          (highest, feed) => feed.id > highest ? feed.id : highest,
        ) +
        1;

    for (final id in persistenceService?.getPinnedHashtagIds() ?? const []) {
      final hashtag = _hashtags[id];
      if (hashtag == null || !_pinnedHashtagIds.add(id)) continue;
      _feedsList.add(_createHashtagFeed(hashtag));
    }
  }

  final List<FeedItem> _feedsList;
  final Map<String, Hashtag> _hashtags;
  final PersistenceService? _persistenceService;
  final Set<String> _pinnedHashtagIds = {};
  FeedItem? _selectedFeed;
  FeedItem? _previousFeed;
  double _navBarScrollOffset = UIConstants.navBarScrollInitialOffset;
  late int _nextFeedId;
  String? _temporaryHashtagId;

  List<FeedItem> get feeds => List.unmodifiable(_feedsList);
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

    if (feed.hashtag == null) _previousFeed = feed;
    _removeTemporaryHashtagFeed();
    _selectedFeed = feed;
    notifyListeners();
  }

  void openHashtag(Hashtag hashtag) {
    if (_selectedFeed?.hashtag == null) _previousFeed = _selectedFeed;
    if (_temporaryHashtagId != hashtag.id) _removeTemporaryHashtagFeed();

    var feed = _feedsList
        .where((item) => item.hashtag?.id == hashtag.id)
        .firstOrNull;
    if (feed == null) {
      _removeTemporaryHashtagFeed();
      feed = _createHashtagFeed(hashtag);
      _feedsList.add(feed);
    }

    _temporaryHashtagId = _pinnedHashtagIds.contains(hashtag.id)
        ? null
        : hashtag.id;
    _selectedFeed = feed;
    notifyListeners();
  }

  bool isHashtagPinned(String id) => _pinnedHashtagIds.contains(id);
  Hashtag? hashtagById(String id) =>
      _hashtags[id] ??
      _hashtags.values.where((hashtag) => hashtag.label == id).firstOrNull;

  void leaveHashtagFeed(String hashtagId) {
    if (_selectedFeed?.hashtag?.id != hashtagId) return;

    _removeTemporaryHashtagFeed();
    _selectedFeed = _previousFeed ?? _feedsList.firstOrNull;
    _previousFeed = null;
    notifyListeners();
  }

  Future<void> toggleHashtagPin(Hashtag hashtag) async {
    final wasPinned = _pinnedHashtagIds.contains(hashtag.id);
    final updatedIds = [..._pinnedHashtagIds];
    if (wasPinned) {
      updatedIds.remove(hashtag.id);
    } else {
      updatedIds.add(hashtag.id);
    }
    await _persistenceService?.setPinnedHashtagIds(updatedIds);

    if (wasPinned) {
      _pinnedHashtagIds.remove(hashtag.id);
      if (_selectedFeed?.hashtag?.id == hashtag.id) {
        _temporaryHashtagId = hashtag.id;
      } else {
        _feedsList.removeWhere((item) => item.hashtag?.id == hashtag.id);
      }
    } else {
      _pinnedHashtagIds.add(hashtag.id);
      if (_temporaryHashtagId == hashtag.id) _temporaryHashtagId = null;
    }
    notifyListeners();
  }

  bool isFeedSelected(int feedId) => _selectedFeed?.id == feedId;

  FeedItem _createHashtagFeed(Hashtag hashtag) => FeedItem(
    id: _nextFeedId++,
    name: hashtag.displayLabel,
    icon: switch (hashtag.type) {
      HashtagType.user => 'tag',
      HashtagType.official => 'verified',
      HashtagType.community => 'groups',
    },
    route: hashtag.route,
    hashtag: hashtag,
  );

  void _removeTemporaryHashtagFeed() {
    final id = _temporaryHashtagId;
    if (id == null) return;
    _feedsList.removeWhere((item) => item.hashtag?.id == id);
    _temporaryHashtagId = null;
  }
}
