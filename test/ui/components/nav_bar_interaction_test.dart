import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
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

  testWidgets('feed tabs remain clickable when a floating app bar reappears', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final feeds = FeedsListProvider([
      const FeedItem(id: 1, name: 'Início', icon: '', route: '/'),
      const FeedItem(id: 2, name: 'Novidades', icon: '', route: '/new'),
    ]);
    final theme = ThemeProvider(PersistenceService(preferences));
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  snap: true,
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(48),
                    child: const NavBar(),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        SizedBox(height: 120, child: Text('Post $index')),
                    childCount: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
        GoRoute(
          path: '/new',
          builder: (context, state) =>
              const Scaffold(body: Text('Novidades da fila')),
        ),
      ],
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: feeds),
          ChangeNotifierProvider.value(value: theme),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -600),
    );
    await tester.pumpAndSettle();
    expect(find.text('Novidades'), findsNothing);

    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, 360),
    );
    await tester.pumpAndSettle();
    final newsTab = find.text('Novidades');
    expect(newsTab, findsOneWidget);
    final tabTapTarget = find
        .ancestor(of: newsTab, matching: find.byType(InkWell))
        .first;
    expect(tester.getSize(tabTapTarget).height, greaterThanOrEqualTo(48));

    await tester.tap(newsTab);
    await tester.pumpAndSettle();

    expect(find.text('Novidades da fila'), findsOneWidget);

    router.dispose();
    feeds.dispose();
    theme.dispose();
  });
}
