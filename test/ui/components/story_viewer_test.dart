import 'package:flutter_test/flutter_test.dart';
import 'package:indigo/model/party/user_profile.dart';
import 'package:indigo/model/post/post.dart';
import 'package:indigo/model/post/post_content.dart';
import 'package:indigo/model/post/post_media.dart';
import 'package:indigo/ui/components/story/story_viewer.dart';
import 'package:indigo/util/const/app/app_strings.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final lucas = _profile('role-lucas-user', 'Lucas Mendes');
  final maya = _profile('role-maya-user', 'Maya Ribeiro');

  UserProfile? authorFor(Post post) =>
      post.authorPartyRoleId == 'role-lucas-user' ? lucas : maya;

  testWidgets('renders the current story author, caption and progress', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: StoryViewer(
          stories: [_story('story-1', 'role-lucas-user', 'Primeira luz')],
          authorFor: authorFor,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Lucas Mendes'), findsOneWidget);
    expect(find.text('Primeira luz'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('falls back to a placeholder when the story has no media', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: StoryViewer(
          stories: [
            _story('story-1', 'role-lucas-user', 'Sem mídia', withMedia: false),
          ],
          authorFor: authorFor,
        ),
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
  });

  testWidgets('advances on a right tap and rewinds on a left tap', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: StoryViewer(
          stories: [
            _story('story-1', 'role-lucas-user', 'Primeira luz'),
            _story('story-2', 'role-maya-user', 'Ouvindo um disco'),
          ],
          authorFor: authorFor,
        ),
      ),
    );
    await tester.pump();

    final controller = tester
        .widget<PageView>(find.byType(PageView))
        .controller!;
    expect(controller.page, 0);

    await tester.tapAt(const Offset(600, 400));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(controller.page, 1);

    await tester.tapAt(const Offset(200, 400));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(controller.page, 0);
  });

  testWidgets('auto advances through the stories and closes at the end', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => StoryViewer(
                      stories: [
                        _story('story-1', 'role-lucas-user', 'Primeira luz'),
                        _story('story-2', 'role-maya-user', 'Ouvindo um disco'),
                      ],
                      authorFor: authorFor,
                    ),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(StoryViewer), findsOneWidget);

    final controller = tester
        .widget<PageView>(find.byType(PageView))
        .controller!;

    await _pumpUntil(tester, () => controller.page == 1);
    expect(controller.page, 1);

    await _pumpUntil(tester, () => find.byType(StoryViewer).evaluate().isEmpty);
    expect(find.byType(StoryViewer), findsNothing);
  });

  testWidgets('closes the viewer with the close button', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => StoryViewer(
                      stories: [_story('story-1', 'role-lucas-user', 'Luz')],
                      authorFor: authorFor,
                    ),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(StoryViewer), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();
    expect(find.byType(StoryViewer), findsNothing);
  });

  testWidgets('renders nothing when there are no stories', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: StoryViewer(stories: const [], authorFor: authorFor),
      ),
    );
    await tester.pump();

    expect(find.byType(PageView), findsNothing);
    expect(find.text(AppStrings.closeStoryViewer), findsNothing);
  });
}

Post _story(
  String id,
  String authorRoleId,
  String caption, {
  bool withMedia = true,
}) => Post(
  id: id,
  authorPartyRoleId: authorRoleId,
  content: PostContent(segments: [PostTextSegment(text: caption)]),
  media: withMedia
      ? [
          PostMedia(
            id: '$id-media',
            type: PostMediaType.image,
            sourceUrl: 'https://example.test/$id.jpg',
            thumbnailUrl: 'https://example.test/$id-thumb.jpg',
          ),
        ]
      : const [],
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

Future<void> _pumpUntil(
  WidgetTester tester,
  bool Function() condition, {
  Duration step = const Duration(milliseconds: 250),
  int maxSteps = 100,
}) async {
  for (var i = 0; i < maxSteps && !condition(); i++) {
    await tester.pump(step);
  }
}
