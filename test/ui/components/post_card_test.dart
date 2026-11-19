import 'package:flutter_test/flutter_test.dart';
import 'package:indigo/model/party/user_profile.dart';
import 'package:indigo/model/post/post.dart';
import 'package:indigo/model/post/post_content.dart';
import 'package:indigo/model/post/post_engagement_summary.dart';
import 'package:indigo/model/post/post_interaction.dart';
import 'package:indigo/model/post/post_location.dart';
import 'package:indigo/ui/components/post/post_author_header.dart';
import 'package:indigo/ui/components/post/post_card.dart';
import 'package:indigo/ui/theme/app_theme.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('shows author metadata and accessible engagement metrics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final publishedAt = DateTime.now().subtract(const Duration(hours: 2));
    final post = Post(
      id: 'post-1',
      authorPartyRoleId: 'role-ana-user',
      content: PostContent(segments: [PostTextSegment(text: 'Hello feed')]),
      createdAt: publishedAt,
      location: const PostLocation(name: 'Parque Ibirapuera'),
      engagement: const PostEngagementSummary(
        commentCount: 8,
        reactionCount: 74,
        shareCount: 12,
        saveCount: 4,
        viewer: PostViewerEngagement(
          reaction: PostReactionType.like,
          isSaved: true,
        ),
      ),
    );
    final author = UserProfile(
      partyId: 'party-ana',
      platformUserRoleId: 'role-ana-user',
      username: 'ana.costa',
      displayName: 'Ana Costa',
      createdAt: DateTime.utc(2024),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PostCard(post: post, author: author),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Ana Costa'), findsOneWidget);
    expect(find.text('@ana.costa'), findsOneWidget);
    expect(find.text('há 2 h'), findsOneWidget);
    expect(find.text('Hello feed'), findsOneWidget);
    expect(find.text('Parque Ibirapuera'), findsOneWidget);
    expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
    expect(
      find.bySemanticsLabel('Localização: Parque Ibirapuera'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.mode_comment_outlined), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(Icons.repeat), findsOneWidget);
    expect(find.byIcon(Icons.bookmark), findsOneWidget);
    expect(find.bySemanticsLabel('Curtidas: 74'), findsOneWidget);
    expect(find.bySemanticsLabel('Comentários: 8'), findsOneWidget);
    expect(find.bySemanticsLabel('Republicações: 12'), findsOneWidget);
    expect(find.bySemanticsLabel('Salvamentos: 4'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('uses the screen surface with no border in both themes', (
    tester,
  ) async {
    final post = Post(
      id: 'post-surface',
      authorPartyRoleId: 'role-ana-user',
      content: PostContent(segments: [PostTextSegment(text: 'Hello feed')]),
      createdAt: DateTime.utc(2026),
    );

    for (final theme in [lightTheme, darkTheme]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(body: PostCard(post: post, author: null)),
        ),
      );

      final cardTheme = theme.cardTheme;
      final shape = cardTheme.shape! as RoundedRectangleBorder;

      expect(cardTheme.color, theme.scaffoldBackgroundColor);
      expect(cardTheme.elevation, 0);
      expect(shape.side, BorderSide.none);
      expect(find.byType(Divider), findsNothing);
      expect(find.byIcon(Icons.location_on_outlined), findsNothing);
    }
  });

  testWidgets(
    'truncates location metadata without overflowing a narrow header',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 190,
              child: PostAuthorHeader(
                author: null,
                publishedAt: DateTime.utc(2026),
                location: const PostLocation(
                  name: 'Parque Nacional da Serra da Cantareira, São Paulo, Brasil',
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
