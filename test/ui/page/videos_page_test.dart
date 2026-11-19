import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indigo/model/post/post.dart';
import 'package:indigo/model/post/post_content.dart';
import 'package:indigo/model/post/post_media.dart';
import 'package:indigo/provider/bottom_navigation_bar/bottom_navigation_provider.dart';
import 'package:indigo/provider/post/posts_provider.dart';
import 'package:indigo/service/post_repository.dart';
import 'package:indigo/service/social_data_service.dart';
import 'package:indigo/ui/page/videos_page.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late VideoPlayerPlatform originalPlatform;
  late _FakeVideoPlayerPlatform fakePlatform;

  setUp(() {
    originalPlatform = VideoPlayerPlatform.instance;
    fakePlatform = _FakeVideoPlayerPlatform();
    VideoPlayerPlatform.instance = fakePlatform;
  });

  tearDown(() {
    VideoPlayerPlatform.instance = originalPlatform;
  });

  testWidgets(
    'preloads the next video and shows loading while it initializes',
    (tester) async {
      fakePlatform.failuresRemaining['https://example.test/video-0.mp4'] = 1;
      final socialDataService = AssetSocialDataService();
      await socialDataService.load();
      final provider = PostsProvider(
        repository: _FakePostRepository([
          for (var index = 0; index < 3; index++) _videoPost(index),
        ]),
        socialDataService: socialDataService,
        clock: () => DateTime.utc(2026, 2),
      );
      await provider.load();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: provider),
            ChangeNotifierProvider(
              create: (_) => BottomNavigationProvider(const []),
            ),
          ],
          child: const MaterialApp(home: VideosPage()),
        ),
      );
      await tester.pump();

      expect(fakePlatform.createdSources, [
        'https://example.test/video-0.mp4',
        'https://example.test/video-1.mp4',
      ]);
      expect(find.byIcon(Icons.refresh), findsOneWidget);

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      await tester.pump();

      expect(fakePlatform.createdSources, [
        'https://example.test/video-0.mp4',
        'https://example.test/video-1.mp4',
        'https://example.test/video-0.mp4',
      ]);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.drag(find.byType(PageView), const Offset(0, -700));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(fakePlatform.createdSources, [
        'https://example.test/video-0.mp4',
        'https://example.test/video-1.mp4',
        'https://example.test/video-0.mp4',
        'https://example.test/video-2.mp4',
      ]);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      fakePlatform.initializeAll();
      await tester.pump();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );
}

Post _videoPost(int index) => Post(
  id: 'post-$index',
  authorPartyRoleId: 'role-ana-user',
  content: PostContent(segments: [PostTextSegment(text: 'Video $index')]),
  media: [
    PostMedia(
      id: 'video-$index',
      type: PostMediaType.video,
      sourceUrl: 'https://example.test/video-$index.mp4',
    ),
  ],
  createdAt: DateTime.utc(2026, 1),
);

class _FakePostRepository implements PostRepository {
  const _FakePostRepository(this.posts);

  final List<Post> posts;

  @override
  Future<List<Post>> loadPosts({bool refresh = false}) async => posts;

  @override
  Future<PostPage> loadPostPage({
    bool refresh = false,
    required int offset,
    required int limit,
  }) async {
    final page = posts.skip(offset).take(limit + 1).toList();
    return PostPage(
      posts: page.take(limit).toList(),
      hasMore: page.length > limit,
    );
  }
}

class _FakeVideoPlayerPlatform extends VideoPlayerPlatform {
  int _nextPlayerId = 0;
  final Map<int, StreamController<VideoEvent>> _events = {};
  final List<String> createdSources = [];
  final Map<String, int> failuresRemaining = {};

  @override
  Future<void> init() async {}

  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async {
    final playerId = _nextPlayerId++;
    final source = options.dataSource.uri!;
    createdSources.add(source);
    final failures = failuresRemaining[source] ?? 0;
    if (failures > 0) {
      failuresRemaining[source] = failures - 1;
      throw PlatformException(code: 'video-initialization-failed');
    }
    _events[playerId] = StreamController<VideoEvent>.broadcast(sync: true);
    return playerId;
  }

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) => _events[playerId]!.stream;

  @override
  Future<void> dispose(int playerId) async {
    await _events.remove(playerId)?.close();
  }

  @override
  Future<void> setLooping(int playerId, bool looping) async {}

  @override
  Future<void> setVolume(int playerId, double volume) async {}

  @override
  Future<void> play(int playerId) async {}

  @override
  Future<void> pause(int playerId) async {}

  @override
  Future<void> seekTo(int playerId, Duration position) async {}

  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async {}

  @override
  Future<Duration> getPosition(int playerId) async => Duration.zero;

  @override
  Widget buildViewWithOptions(VideoViewOptions options) =>
      const SizedBox.expand();

  void initializeAll() {
    for (final eventController in _events.values) {
      eventController.add(
        VideoEvent(
          eventType: VideoEventType.initialized,
          duration: const Duration(minutes: 1),
          size: const Size(720, 1280),
        ),
      );
    }
  }
}
