import 'package:flutter_test/flutter_test.dart';
import 'package:indigo/model/party/user_profile.dart';
import 'package:indigo/model/post/post.dart';
import 'package:indigo/model/post/post_content.dart';
import 'package:indigo/ui/components/avatar.dart';
import 'package:indigo/ui/components/story/stories_row.dart';
import 'package:indigo/ui/components/story/story_viewer.dart';
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

  testWidgets('opens the story viewer when a story is tapped', (tester) async {
    final author = _profile('role-lucas-user', 'Lucas Mendes');
    final story = _story('story-1', 'role-lucas-user');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StoriesRow(stories: [story], authorFor: (_) => author),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lucas Mendes'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(StoryViewer), findsOneWidget);
  });

  testWidgets('groups multiple stories from the same profile into one entry', (
    tester,
  ) async {
    final author = _profile('role-lucas-user', 'Lucas Mendes');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StoriesRow(
            stories: [
              _story('story-1', 'role-lucas-user'),
              _story('story-2', 'role-lucas-user'),
            ],
            authorFor: (_) => author,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Lucas Mendes'), findsOneWidget);
    expect(find.byType(Avatar), findsOneWidget);
  });

  testWidgets('skips the current user profile from the friend entries', (
    tester,
  ) async {
    final me = _profile('role-me', 'Ana Costa');
    final friend = _profile('role-lucas-user', 'Lucas Mendes');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StoriesRow(
            stories: [
              _story('mine', 'role-me'),
              _story('friend', 'role-lucas-user'),
            ],
            authorFor: (post) =>
                post.authorPartyRoleId == 'role-me' ? me : friend,
            currentUser: me,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.yourStory), findsOneWidget);
    expect(find.text('Ana Costa'), findsNothing);
    expect(find.text('Lucas Mendes'), findsOneWidget);
    expect(find.byType(Avatar), findsNWidgets(2));
  });

  testWidgets('opens the viewer at the first story of the tapped profile', (
    tester,
  ) async {
    final lucas = _profile('role-lucas-user', 'Lucas Mendes');
    final maya = _profile('role-maya-user', 'Maya Ribeiro');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StoriesRow(
            stories: [
              _story('lucas-1', 'role-lucas-user'),
              _story('lucas-2', 'role-lucas-user'),
              _story('maya-1', 'role-maya-user'),
            ],
            authorFor: (post) =>
                post.authorPartyRoleId == 'role-lucas-user' ? lucas : maya,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Maya Ribeiro'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(StoryViewer), findsOneWidget);
    final controller = tester
        .widget<PageView>(find.byType(PageView))
        .controller!;
    expect(controller.page, 2);
  });

  testWidgets('dims only the rings of fully seen profiles', (tester) async {
    final lucas = _profile('role-lucas-user', 'Lucas Mendes');
    final maya = _profile('role-maya-user', 'Maya Ribeiro');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StoriesRow(
            stories: [
              _story('lucas-1', 'role-lucas-user'),
              _story('maya-1', 'role-maya-user'),
            ],
            authorFor: (post) =>
                post.authorPartyRoleId == 'role-lucas-user' ? lucas : maya,
            seenStoryIds: const {'lucas-1'},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(_ringGradient(tester, 'Lucas Mendes'), isNull);
    expect(_ringGradient(tester, 'Maya Ribeiro'), isNotNull);
  });

  testWidgets('opens the viewer at the first unseen story of a profile', (
    tester,
  ) async {
    final lucas = _profile('role-lucas-user', 'Lucas Mendes');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StoriesRow(
            stories: [
              _story('lucas-1', 'role-lucas-user'),
              _story('lucas-2', 'role-lucas-user'),
              _story('lucas-3', 'role-lucas-user'),
            ],
            authorFor: (_) => lucas,
            seenStoryIds: const {'lucas-1'},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lucas Mendes'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(StoryViewer), findsOneWidget);
    final controller = tester
        .widget<PageView>(find.byType(PageView))
        .controller!;
    expect(controller.page, 1);
  });
}

LinearGradient? _ringGradient(WidgetTester tester, String label) {
  final ringContainers = find.descendant(
    of: find
        .ancestor(of: find.text(label), matching: find.byType(InkWell))
        .first,
    matching: find.byType(Container),
  );
  for (final container in tester.widgetList<Container>(ringContainers)) {
    final decoration = container.decoration;
    if (decoration is BoxDecoration && decoration.shape == BoxShape.circle) {
      return decoration.gradient as LinearGradient?;
    }
  }
  return null;
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
