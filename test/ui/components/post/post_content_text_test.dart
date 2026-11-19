import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:indigo/model/feed_item.dart';
import 'package:indigo/model/hashtag.dart';
import 'package:indigo/model/post/post_content.dart';
import 'package:indigo/provider/feed/feeds_list_provider.dart';
import 'package:indigo/ui/components/post/post_content_text.dart';
import 'package:indigo/util/const/ui/ui_constants.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('hashtag text opens its feed and selects a navigation tab', (
    tester,
  ) async {
    const hashtag = Hashtag(
      id: 'tag-dias-leves',
      label: 'diasleves',
      type: HashtagType.user,
      emoji: '🌿',
    );
    final feeds = FeedsListProvider(
      [const FeedItem(id: 1, name: 'Início', icon: '', route: '/')],
      hashtags: [hashtag],
    );
    final content = PostContent(
      segments: [
        PostTextSegment(
          text: '#diasleves',
          entity: const PostTextEntity(
            type: PostTextEntityType.hashtag,
            value: 'diasleves',
            id: 'tag-dias-leves',
          ),
        ),
      ],
    );
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: Center(child: PostContentText(content: content)),
          ),
        ),
        GoRoute(
          path: '/hashtags/:hashtagId',
          builder: (context, state) => Scaffold(
            body: Text('Feed: ${state.pathParameters['hashtagId']}'),
          ),
        ),
        GoRoute(
          path: '/article',
          builder: (context, state) => Scaffold(
            body: Center(
              child: PostContentText(content: content, selectable: true),
            ),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider.value(value: feeds)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();

    final text = tester.widget<Text>(
      find.descendant(
        of: find.byType(PostContentText),
        matching: find.byType(Text),
      ),
    );
    final link = (text.textSpan! as TextSpan).children!.single as TextSpan;
    expect(link.text, '🌿\u00A0#diasleves');
    expect(link.style?.fontWeight, FontWeight.bold);
    expect(link.style?.color, UIConstants.lightHashtagLinkColor);
    expect(link.style?.decoration, TextDecoration.none);

    await tester.tap(find.byType(RichText));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Feed: tag-dias-leves'), findsOneWidget);
    expect(feeds.selectedFeed?.hashtag?.id, 'tag-dias-leves');

    feeds.selectFeed(1);
    router.go('/article');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byType(SelectableText));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Feed: tag-dias-leves'), findsOneWidget);

    router.dispose();
    feeds.dispose();
  });
}
