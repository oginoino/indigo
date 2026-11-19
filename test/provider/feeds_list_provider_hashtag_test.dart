import 'package:flutter_test/flutter_test.dart';
import 'package:indigo/model/feed_item.dart';
import 'package:indigo/model/hashtag.dart';
import 'package:indigo/provider/feed/feeds_list_provider.dart';
import 'package:indigo/service/persistence/persistence_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const home = FeedItem(id: 1, name: 'Início', icon: '', route: '/');
  const hashtag = Hashtag(
    id: 'tag-design',
    label: 'design',
    type: HashtagType.community,
    emoji: '🎨',
    communityId: 'community-design',
  );

  test('removes an unpinned hashtag tab when another feed is selected', () {
    final provider = FeedsListProvider([home], hashtags: [hashtag]);

    provider.openHashtag(hashtag);
    expect(provider.feeds.map((feed) => feed.hashtag?.id), [null, hashtag.id]);
    expect(provider.selectedFeed?.route, hashtag.route);

    provider.selectFeed(home.id);

    expect(provider.feeds, [home]);
    expect(provider.selectedFeed, home);
    provider.dispose();
  });

  test('restores the previous feed when a hashtag route is left', () {
    const videos = FeedItem(id: 2, name: 'Vídeos', icon: '', route: '/videos');
    final provider = FeedsListProvider([home, videos], hashtags: [hashtag]);

    provider.selectFeed(videos.id);
    provider.openHashtag(hashtag);
    provider.leaveHashtagFeed(hashtag.id);

    expect(provider.selectedFeed, videos);
    expect(provider.feeds, [home, videos]);
    provider.dispose();
  });

  test(
    'restores pinned tabs and removes them after unpinning and leaving',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final persistence = PersistenceService(preferences);

      final provider = FeedsListProvider(
        [home],
        hashtags: [hashtag],
        persistenceService: persistence,
      );
      provider.openHashtag(hashtag);
      await provider.toggleHashtagPin(hashtag);
      provider.dispose();

      final restored = FeedsListProvider(
        [home],
        hashtags: [hashtag],
        persistenceService: persistence,
      );
      expect(restored.isHashtagPinned(hashtag.id), isTrue);
      expect(restored.feeds.last.hashtag, hashtag);

      restored.openHashtag(hashtag);
      await restored.toggleHashtagPin(hashtag);
      expect(restored.feeds.last.hashtag, hashtag);
      expect(restored.isHashtagPinned(hashtag.id), isFalse);

      restored.selectFeed(home.id);
      expect(restored.feeds, [home]);
      restored.dispose();
    },
  );
}
