import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indigo/model/post/post_media.dart';
import 'package:indigo/ui/components/post/post_audio_player.dart';
import 'package:indigo/util/const/app/app_strings.dart';
import 'package:material_ui/material_ui.dart';
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

  testWidgets('plays, seeks and reports the current position', (tester) async {
    await tester.pumpWidget(_playerApp(_audio(id: 'note-1')));
    await tester.pump();
    fakePlatform.initializeAll();
    await tester.pump();

    expect(find.text('1:05'), findsOneWidget);
    expect(find.byTooltip(AppStrings.playAudio), findsOneWidget);

    await tester.tap(find.byTooltip(AppStrings.forwardAudio));
    await tester.pump();

    expect(find.text('0:05'), findsOneWidget);

    await tester.tap(find.byKey(PostAudioPlayer.waveformKey));
    await tester.pump();

    expect(find.text('0:32'), findsOneWidget);

    await tester.tap(find.byTooltip(AppStrings.playAudio));
    await tester.pump();

    expect(find.byTooltip(AppStrings.pauseAudio), findsOneWidget);
  });

  testWidgets('pauses the previous clip when another one starts', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              _playerApp(_audio(id: 'note-1'), wrapApp: false),
              _playerApp(_audio(id: 'note-2'), wrapApp: false),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    fakePlatform.initializeAll();
    await tester.pump();

    await tester.tap(find.byTooltip(AppStrings.playAudio).first);
    await tester.pump();

    expect(find.byIcon(Icons.pause), findsOneWidget);

    await tester.tap(find.byTooltip(AppStrings.playAudio));
    await tester.pump();

    expect(find.byIcon(Icons.pause), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });

  testWidgets('shows a retry when playback cannot start', (tester) async {
    fakePlatform.failuresRemaining['https://example.test/note.mp3'] = 1;

    await tester.pumpWidget(_playerApp(_audio(id: 'note-1')));
    await tester.pump();
    await tester.pump();

    expect(find.text(AppStrings.audioPlaybackFailed), findsOneWidget);

    await tester.tap(find.byTooltip(AppStrings.retry));
    await tester.pump();
    fakePlatform.initializeAll();
    await tester.pump();

    expect(find.text(AppStrings.audioPlaybackFailed), findsNothing);
    expect(find.byTooltip(AppStrings.playAudio), findsOneWidget);
  });
}

PostMedia _audio({required String id}) => PostMedia(
  id: id,
  type: PostMediaType.audio,
  sourceUrl: 'https://example.test/note.mp3',
  altText: 'Recado de voz',
  duration: const Duration(seconds: 12),
  waveform: const [0.2, 0.8, 0.5, 0.4],
);

Widget _playerApp(PostMedia media, {bool wrapApp = true}) {
  final player = SizedBox(
    width: 360,
    child: PostAudioPlayer(media: media),
  );
  if (!wrapApp) return player;
  return MaterialApp(
    home: Scaffold(body: Center(child: player)),
  );
}

class _FakeVideoPlayerPlatform extends VideoPlayerPlatform {
  int _nextPlayerId = 0;
  final Map<int, StreamController<VideoEvent>> _events = {};
  final Map<String, int> failuresRemaining = {};

  @override
  Future<void> init() async {}

  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async {
    final source = options.dataSource.uri!;
    final failures = failuresRemaining[source] ?? 0;
    if (failures > 0) {
      failuresRemaining[source] = failures - 1;
      throw PlatformException(code: 'audio-initialization-failed');
    }

    final playerId = _nextPlayerId++;
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
  Future<void> play(int playerId) async {
    _events[playerId]?.add(
      VideoEvent(eventType: VideoEventType.isPlayingStateUpdate, isPlaying: true),
    );
  }

  @override
  Future<void> pause(int playerId) async {
    _events[playerId]?.add(
      VideoEvent(
        eventType: VideoEventType.isPlayingStateUpdate,
        isPlaying: false,
      ),
    );
  }

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
    for (final eventController in _events.values.toList()) {
      eventController.add(
        VideoEvent(
          eventType: VideoEventType.initialized,
          duration: const Duration(seconds: 65),
          size: Size.zero,
        ),
      );
    }
  }
}
