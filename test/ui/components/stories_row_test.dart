import 'package:flutter_test/flutter_test.dart';
import 'package:indigo/model/party/user_profile.dart';
import 'package:indigo/model/post/post.dart';
import 'package:indigo/model/post/post_content.dart';
import 'package:indigo/ui/components/avatar.dart';
import 'package:indigo/ui/components/story/stories_row.dart';
import 'package:indigo/util/const/app/app_strings.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows the current user entry and friend stories', (
    tester,
  ) async {
    final currentUser = _profile('role-me', 'Ana Costa');
    final author = _profile('role-lucas-user', 'Lucas Mendes');
    final story = _story('story-1', 'role-lucas-user');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StoriesRow(
            stories: [story],
            authorFor: (_) => author,
            currentUser: currentUser,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.yourStory), findsOneWidget);
    expect(find.text('Lucas Mendes'), findsOneWidget);
    expect(find.byType(Avatar), findsNWidgets(2));
  });

  testWidgets('renders nothing without stories or a current user', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StoriesRow(stories: const [], authorFor: (_) => null),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Avatar), findsNothing);
  });

  testWidgets('falls back to an unknown author label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StoriesRow(
            stories: [_story('story-2', 'role-rafa-user')],
            authorFor: (_) => null,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.unknownPostAuthor), findsOneWidget);
  });
}

Post _story(String id, String authorRoleId) => Post(
  id: id,
  authorPartyRoleId: authorRoleId,
  content: PostContent(segments: [PostTextSegment(text: id)]),
  createdAt: DateTime.utc(2026),
  expiresAt: DateTime.utc(2026).add(const Duration(hours: 24)),
);

UserProfile _profile(String roleId, String displayName) => UserProfile(
  partyId: 'party-$roleId',
  platformUserRoleId: roleId,
  username: roleId,
  displayName: displayName,
  createdAt: DateTime.utc(2024),
);
