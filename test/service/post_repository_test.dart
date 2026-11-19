import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:indigo/service/persistence/post_local_persistence_service.dart';
import 'package:indigo/service/post_repository.dart';
import 'package:indigo/service/social_data_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AssetPostRepository', () {
    late SharedPreferences preferences;
    late AssetSocialDataService socialDataService;
    late PostLocalPersistenceService localPersistence;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      preferences = await SharedPreferences.getInstance();
      socialDataService = AssetSocialDataService();
      await socialDataService.load();
      localPersistence = PostLocalPersistenceService(preferences);
    });

    test('maps fixture posts and persists the cache locally', () async {
      final repository = AssetPostRepository(
        socialDataService: socialDataService,
        localPersistence: localPersistence,
      );

      final posts = await repository.loadPosts();
      final videoPost = posts.singleWhere(
        (post) => post.id == 'post-night-market',
      );
      final videoMedia = videoPost.media.singleWhere((media) => media.isVideo);

      final audioPost = posts.singleWhere((post) => post.id == 'post-voice-note');
      final audioMedia = audioPost.media.singleWhere((media) => media.isAudio);

      expect(posts, isNotEmpty);
      expect(videoMedia.duration, const Duration(seconds: 18));
      expect(audioMedia.duration, const Duration(seconds: 2));
      expect(audioMedia.waveform, isNotEmpty);
      expect(audioPost.media.where((media) => media.isVisual), isNotEmpty);
      expect(preferences.getString('socialPostsCache'), isNotNull);
    });

    test('refresh replaces cached posts from the mock source', () async {
      await localPersistence.savePosts(
        schemaVersion: socialDataService.data.schemaVersion,
        posts: const [
          {'id': 'stale-post'},
        ],
      );
      final repository = AssetPostRepository(
        socialDataService: socialDataService,
        localPersistence: localPersistence,
      );

      final posts = await repository.loadPosts(refresh: true);

      expect(posts.map((post) => post.id), isNot(contains('stale-post')));
    });

    test(
      'invalidates an older fixture cache after its version changes',
      () async {
        await localPersistence.savePosts(
          schemaVersion: socialDataService.data.schemaVersion - 1,
          posts: const [
            {'id': 'stale-post'},
          ],
        );
        final repository = AssetPostRepository(
          socialDataService: socialDataService,
          localPersistence: localPersistence,
        );

        final posts = await repository.loadPosts();
        final videoPost = posts.singleWhere(
          (post) => post.id == 'post-long-video',
        );

        expect(posts.map((post) => post.id), isNot(contains('stale-post')));
        expect(
          videoPost.media.single.sourceUrl,
          contains('interactive-examples'),
        );
      },
    );

    test('loads post pages with a continuation flag', () async {
      final repository = AssetPostRepository(
        socialDataService: socialDataService,
        localPersistence: localPersistence,
      );

      final firstPage = await repository.loadPostPage(offset: 0, limit: 2);
      final secondPage = await repository.loadPostPage(offset: 2, limit: 2);

      expect(firstPage.posts, hasLength(2));
      expect(firstPage.hasMore, isTrue);
      expect(secondPage.posts, isNotEmpty);
      expect(
        secondPage.posts.map((post) => post.id),
        isNot(contains(firstPage.posts.first.id)),
      );
    });

    test(
      'loads persisted post data without replacing it from the fixture',
      () async {
        final repository = AssetPostRepository(
          socialDataService: socialDataService,
          localPersistence: localPersistence,
        );
        final initialPosts = await repository.loadPosts();
        final cachedJson = jsonDecode(
          preferences.getString('socialPostsCache')!,
        ) as Map<String, dynamic>;
        final cachedPosts = List<Map<String, dynamic>>.from(
          cachedJson['posts'] as List,
        );
        final firstPost = Map<String, dynamic>.from(cachedPosts.first);
        final content = Map<String, dynamic>.from(
          firstPost['content'] as Map<String, dynamic>,
        );
        final segments = List<Map<String, dynamic>>.from(
          content['segments'] as List,
        );
        segments.first = {...segments.first, 'text': 'Loaded from cache'};
        content['segments'] = segments;
        firstPost['content'] = content;
        cachedPosts.first = firstPost;
        cachedJson['posts'] = cachedPosts;
        await preferences.setString('socialPostsCache', jsonEncode(cachedJson));

        final loadedPosts = await repository.loadPosts();

        expect(initialPosts, isNotEmpty);
        expect(
          loadedPosts.first.content.plainText,
          startsWith('Loaded from cache'),
        );
      },
    );
  });
}
