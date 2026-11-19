import 'package:flutter_test/flutter_test.dart';
import 'package:indigo/model/feed_item.dart';
import 'package:indigo/provider/feed/feeds_list_provider.dart';
import 'package:indigo/provider/theme/theme_provider.dart';
import 'package:indigo/service/persistence/persistence_service.dart';
import 'package:indigo/ui/components/app_bar/nav_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('long press reorders feeds but leaves fixed feeds in place', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final feeds = FeedsListProvider([
      const FeedItem(id: 1, name: 'Descobrir', icon: '', route: '/discover'),
      const FeedItem(id: 2, name: 'Amigos', icon: '', route: '/friends'),
      const FeedItem(
        id: 3,
        name: 'Comunidades',
        icon: '',
        route: '/communities',
      ),
      const FeedItem(id: 4, name: 'Notícias', icon: '', route: '/news'),
    ]);
    final theme = ThemeProvider(PersistenceService(preferences));

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: feeds),
          ChangeNotifierProvider.value(value: theme),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Align(alignment: Alignment.topLeft, child: NavBar()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final newsCenter = tester.getCenter(find.text('Notícias'));
    final communityCenter = tester.getCenter(find.text('Comunidades'));
    final reorderGesture = await tester.startGesture(newsCenter);
    await tester.pump(const Duration(milliseconds: 600));
    await reorderGesture.moveTo(communityCenter);
    await tester.pump(const Duration(milliseconds: 300));
    await reorderGesture.up();
    await tester.pumpAndSettle();

    expect(feeds.feeds.map((feed) => feed.route), [
      '/discover',
      '/friends',
      '/news',
      '/communities',
    ]);

    final discoverCenter = tester.getCenter(find.text('Descobrir'));
    final newsTargetCenter = tester.getCenter(find.text('Notícias'));
    final fixedGesture = await tester.startGesture(discoverCenter);
    await tester.pump(const Duration(milliseconds: 600));
    await fixedGesture.moveTo(newsTargetCenter);
    await tester.pump(const Duration(milliseconds: 300));
    await fixedGesture.up();
    await tester.pumpAndSettle();

    expect(feeds.feeds.map((feed) => feed.route), [
      '/discover',
      '/friends',
      '/news',
      '/communities',
    ]);

    feeds.dispose();
    theme.dispose();
  });
}
