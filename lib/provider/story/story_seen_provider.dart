import 'package:flutter/foundation.dart';

class StorySeenProvider extends ChangeNotifier {
  final Set<String> _seenStoryIds = <String>{};

  Set<String> get seenStoryIds => Set.unmodifiable(_seenStoryIds);

  bool isSeen(String storyId) => _seenStoryIds.contains(storyId);

  void markSeen(String storyId) {
    if (_seenStoryIds.add(storyId)) notifyListeners();
  }
}
