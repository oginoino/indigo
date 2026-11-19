import 'package:flutter_test/flutter_test.dart';
import 'package:indigo/model/post/post.dart';
import 'package:indigo/model/post/post_content.dart';
import 'package:indigo/model/post/post_engagement_summary.dart';
import 'package:indigo/ui/components/post/post_card.dart';
import 'package:indigo/util/const/app/app_strings.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('opens long post content in a readable article view', (
    tester,
  ) async {
    final content = List.filled(
      24,
      'Uma boa história merece espaço para ser lida com calma.',
    ).join(' ');

    await tester.pumpWidget(_postCardApp(content));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.postReadMore), findsOneWidget);

    await tester.ensureVisible(find.text(AppStrings.postReadMore));
    await tester.tap(find.text(AppStrings.postReadMore));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.postArticleTitle), findsOneWidget);
    expect(find.byType(SelectableText), findsOneWidget);
    expect(find.text(content), findsOneWidget);
  });

  testWidgets('does not show a read-more action for short content', (
    tester,
  ) async {
    await tester.pumpWidget(_postCardApp('Uma publicação breve.'));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.postReadMore), findsNothing);
  });
}

Widget _postCardApp(String content) => MaterialApp(
  home: Scaffold(
    body: ListView(
      children: [
        PostCard(
          post: Post(
            id: 'post-long-text',
            authorPartyRoleId: 'role-ana-user',
            title: 'Uma história completa',
            content: PostContent(segments: [PostTextSegment(text: content)]),
            createdAt: DateTime.utc(2026),
            engagement: const PostEngagementSummary(),
          ),
          author: null,
        ),
      ],
    ),
  ),
);
