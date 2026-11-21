import 'package:flutter_test/flutter_test.dart';
import 'package:indigo/di/di.dart';
import 'package:indigo/provider/story/story_seen_provider.dart';

void main() {
  group('StorySeenProvider', () {
    test('starts empty and reports unseen stories', () {
      final provider = StorySeenProvider(preferences: sharedPreferences);

      expect(provider.seenStoryIds, isEmpty);
      expect(provider.isSeen('story-1'), isFalse);
      provider.dispose();
    });

    test('marks stories as seen and notifies listeners once', () {
      final provider = StorySeenProvider(preferences: sharedPreferences);
      var notifications = 0;
      provider.addListener(() => notifications++);

      provider.markSeen('story-1');
      provider.markSeen('story-1');

      expect(provider.isSeen('story-1'), isTrue);
      expect(notifications, 1);
      provider.dispose();
    });

    test('exposes an unmodifiable set of seen ids', () {
      final provider = StorySeenProvider(preferences: sharedPreferences);
      provider.markSeen('story-1');

      expect(provider.seenStoryIds, contains('story-1'));
      expect(
        () => provider.seenStoryIds.add('story-2'),
        throwsUnsupportedError,
      );
      provider.dispose();
    });
  });
}
