import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/post/post.dart'; // ajuste o caminho

/// Guarda quais stories já foram vistos, persiste entre sessões e expõe
/// consultas usadas pela fila de stories.
class StorySeenProvider extends ChangeNotifier {
  StorySeenProvider({SharedPreferences? preferences})
    : _preferences = preferences {
    final saved = preferences?.getStringList(_storageKey);
    if (saved != null) _seenStoryIds.addAll(saved);
  }

  static const String _storageKey = 'seen_story_ids';

  /// Limite de ids guardados: stories expiram, então não faz sentido
  /// acumular para sempre. Os mais antigos são descartados primeiro.
  static const int _maxStoredIds = 500;

  final SharedPreferences? _preferences;

  // Set literal é um LinkedHashSet: mantém a ordem de inserção.
  final Set<String> _seenStoryIds = <String>{};
  bool _disposed = false;

  Set<String> get seenStoryIds => UnmodifiableSetView(_seenStoryIds);

  bool isSeen(String storyId) => _seenStoryIds.contains(storyId);

  /// Todos os stories da lista já foram vistos.
  bool hasSeenAll(Iterable<Post> stories) =>
      stories.every((story) => _seenStoryIds.contains(story.id));

  /// Índice do primeiro story não visto, ou -1 se todos foram vistos.
  int firstUnseenIndex(List<Post> stories) =>
      stories.indexWhere((story) => !_seenStoryIds.contains(story.id));

  void markSeen(String storyId) {
    if (!_seenStoryIds.add(storyId)) return;

    while (_seenStoryIds.length > _maxStoredIds) {
      _seenStoryIds.remove(_seenStoryIds.first);
    }

    unawaited(_persist());
    _notifySafely();
  }

  Future<void> _persist() async {
    try {
      await _preferences?.setStringList(
        _storageKey,
        _seenStoryIds.toList(growable: false),
      );
    } catch (error, stackTrace) {
      // Falha ao persistir não deve quebrar a UI; o estado em memória vale.
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'StorySeenProvider',
        ),
      );
    }
  }

  /// Se for chamado durante o build/layout (ex.: no initState do viewer),
  /// adia o aviso para depois do frame e evita
  /// "setState() called during build".
  void _notifySafely() {
    final binding = SchedulerBinding.instance;
    if (binding.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      binding.addPostFrameCallback((_) {
        if (!_disposed) notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}