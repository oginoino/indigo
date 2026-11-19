import 'package:flutter_test/flutter_test.dart';
import 'package:indigo/model/post/post.dart';
import 'package:indigo/model/post/post_content.dart';
import 'package:indigo/ui/components/post/post_engagement_bar.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('exposes icon button callbacks in both layouts', (tester) async {
    final post = Post(
      id: 'post-actions',
      authorPartyRoleId: 'role-ana-user',
      content: PostContent(segments: [PostTextSegment(text: 'Hello feed')]),
      createdAt: DateTime.utc(2026),
    );
    final calls = <String>[];
    final callbacks = [
      () => calls.add('comment'),
      () => calls.add('like'),
      () => calls.add('repost'),
      () => calls.add('save'),
    ];

    for (final layout in PostEngagementLayout.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostEngagementBar(
              post: post,
              layout: layout,
              onComment: callbacks[0],
              onLike: callbacks[1],
              onRepost: callbacks[2],
              onSave: callbacks[3],
            ),
          ),
        ),
      );

      expect(find.byType(IconButton), findsNWidgets(4));
      for (var index = 0; index < callbacks.length; index++) {
        await tester.tap(find.byType(IconButton).at(index));
      }
      expect(calls, ['comment', 'like', 'repost', 'save']);
      calls.clear();
    }
  });
}
