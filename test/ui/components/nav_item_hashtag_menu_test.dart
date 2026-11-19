import 'package:flutter_test/flutter_test.dart';
import 'package:indigo/model/feed_item.dart';
import 'package:indigo/model/hashtag.dart';
import 'package:indigo/provider/feed/feeds_list_provider.dart';
import 'package:indigo/service/persistence/persistence_service.dart';
import 'package:indigo/ui/components/app_bar/nav_item.dart';
import 'package:indigo/util/const/app/app_strings.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('selected hashtag chevron menu pins and unpins its feed', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    const hashtag = Hashtag(
      id: 'tag-fotografia',
      label: 'fotografia',
      type: HashtagType.official,
      emoji: '📷',
    );
    final feeds = FeedsListProvider(
      [const FeedItem(id: 1, name: 'Início', icon: '', route: '/')],
      hashtags: [hashtag],
      persistenceService: PersistenceService(preferences),
    )..openHashtag(hashtag);
    expect(feeds.selectedFeed?.id, 2);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: feeds,
        child: const MaterialApp(
          home: Scaffold(
            body: NavItem(
              feedItem: FeedItem(
                id: 2,
                name: '📷 #fotografia',
                icon: 'verified',
                route: '/hashtags/tag-fotografia',
                hashtag: hashtag,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final menuButton = find.byWidgetPredicate(
      (widget) => widget is PopupMenuButton,
    );
    expect(menuButton, findsOneWidget);
    expect(find.byIcon(Icons.push_pin), findsNothing);
    await tester.tap(menuButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.pinHashtag));
    await tester.pumpAndSettle();

    expect(feeds.isHashtagPinned(hashtag.id), isTrue);

    await tester.tap(menuButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.unpinHashtag));
    await tester.pumpAndSettle();

    expect(feeds.isHashtagPinned(hashtag.id), isFalse);
    feeds.dispose();
  });
}
