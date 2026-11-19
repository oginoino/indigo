import 'dart:async';

import 'package:video_player/video_player.dart';

typedef VideoPlaybackErrorHandler = void Function(
  Object error,
  StackTrace stackTrace,
);

class VideoPlaybackSource {
  const VideoPlaybackSource({required this.id, required this.sourceUrl});

  final String id;
  final String sourceUrl;
}

class VideoPlaybackEntry {
  VideoPlaybackEntry._(this.sourceUrl)
    : controller = VideoPlayerController.networkUrl(Uri.parse(sourceUrl)) {
    initialization = _initialize();
  }

  final String sourceUrl;
  final VideoPlayerController controller;
  late final Future<void> initialization;
  bool _isDisposed = false;

  Future<void> _initialize() async {
    await controller.initialize();
    await controller.setLooping(true);
  }

  void dispose(VideoPlaybackErrorHandler onError) {
    if (_isDisposed) return;
    _isDisposed = true;

    final release = initialization.then<void>(
      (_) => controller.dispose(),
      onError: (Object error, StackTrace stackTrace) => controller.dispose(),
    );
    unawaited(release.catchError(onError));
  }
}

class VideoPlaybackManager {
  VideoPlaybackManager({required this.onError, int initialIndex = 0})
    : _currentIndex = initialIndex;

  final VideoPlaybackErrorHandler onError;
  final Map<String, VideoPlaybackEntry> _entries = {};
  List<VideoPlaybackSource> _sources = const [];
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void updateSources(List<VideoPlaybackSource> sources) {
    final previousActive = _sourceAt(_currentIndex);
    _sources = List.unmodifiable(sources);
    if (_currentIndex > _sources.length) {
      _currentIndex = _sources.isEmpty ? 0 : _sources.length - 1;
    }

    final active = _sourceAt(_currentIndex);
    if (previousActive?.id != active?.id) {
      final previousEntry = previousActive == null
          ? null
          : _entries[previousActive.id];
      if (previousEntry != null) _pause(previousEntry.controller);
    }

    _syncControllerWindow();
    _playCurrentController();
  }

  void setCurrentIndex(int index) {
    if (index < 0 || index > _sources.length || index == _currentIndex) return;

    final previous = _sourceAt(_currentIndex);
    if (previous != null) {
      final previousEntry = _entries[previous.id];
      if (previousEntry != null) _pause(previousEntry.controller);
    }

    _currentIndex = index;
    _syncControllerWindow();
    _playCurrentController();
  }

  bool isWithinPreloadWindow(int index) =>
      index >= 0 &&
      index < _sources.length &&
      (index - _currentIndex).abs() <= 1;

  VideoPlaybackEntry entryAt(int index) {
    if (!isWithinPreloadWindow(index)) {
      throw RangeError.index(index, _sources, 'index');
    }
    return _ensureEntry(index);
  }

  void retry(String id) {
    final index = _sources.indexWhere((source) => source.id == id);
    if (index < 0) return;

    _entries.remove(id)?.dispose(onError);
    _syncControllerWindow();
  }

  void dispose() {
    for (final entry in _entries.values) {
      entry.dispose(onError);
    }
    _entries.clear();
  }

  VideoPlaybackSource? _sourceAt(int index) =>
      index < 0 || index >= _sources.length ? null : _sources[index];

  VideoPlaybackEntry _ensureEntry(int index) {
    final source = _sources[index];
    final existing = _entries[source.id];
    if (existing != null && existing.sourceUrl == source.sourceUrl) {
      return existing;
    }

    existing?.dispose(onError);
    final entry = VideoPlaybackEntry._(source.sourceUrl);
    _entries[source.id] = entry;
    entry.initialization.then<void>((_) {
      final active = _sourceAt(_currentIndex);
      if (active?.id == source.id && identical(_entries[source.id], entry)) {
        _play(entry.controller);
      }
    }, onError: onError);
    return entry;
  }

  void _syncControllerWindow() {
    if (_sources.isEmpty) {
      for (final entry in _entries.values) {
        entry.dispose(onError);
      }
      _entries.clear();
      return;
    }

    final firstIndex = _currentIndex > 0 ? _currentIndex - 1 : 0;
    final lastIndex = _currentIndex + 1 < _sources.length
        ? _currentIndex + 1
        : _sources.length - 1;
    final retainedIds = <String>{};

    for (var index = firstIndex; index <= lastIndex; index++) {
      final source = _sources[index];
      retainedIds.add(source.id);
      _ensureEntry(index);
    }

    final expiredIds = _entries.keys
        .where((id) => !retainedIds.contains(id))
        .toList(growable: false);
    for (final id in expiredIds) {
      _entries.remove(id)?.dispose(onError);
    }
  }

  void _playCurrentController() {
    final active = _sourceAt(_currentIndex);
    if (active == null) return;
    final entry = _entries[active.id];
    if (entry != null) _play(entry.controller);
  }

  void _play(VideoPlayerController controller) {
    if (!controller.value.isInitialized || controller.value.isPlaying) return;
    unawaited(controller.play().catchError(onError));
  }

  void _pause(VideoPlayerController controller) {
    if (!controller.value.isInitialized || !controller.value.isPlaying) return;
    unawaited(controller.pause().catchError(onError));
  }
}
