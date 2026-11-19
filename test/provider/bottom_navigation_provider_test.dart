import 'package:flutter_test/flutter_test.dart';
import 'package:indigo/model/bottom_navigation_item.dart';
import 'package:indigo/provider/bottom_navigation_bar/bottom_navigation_provider.dart';

void main() {
  const items = [
    BottomNavigationItem(id: 1, name: 'Home', icon: 'home', route: '/'),
    BottomNavigationItem(
      id: 2,
      name: 'Profile',
      icon: 'person',
      route: '/profile',
    ),
  ];

  group('BottomNavigationProvider', () {
    test('selects the first configured item initially', () {
      final provider = BottomNavigationProvider(items);

      expect(provider.selectedItem, items.first);
    });

    test('selects configured items and ignores unknown items', () {
      final provider = BottomNavigationProvider(items);
      var notifications = 0;
      provider.addListener(() => notifications++);

      provider.selectItem(items.last);
      provider.selectItem(
        const BottomNavigationItem(
          id: 3,
          name: 'Unknown',
          icon: 'circle',
          route: '/unknown',
        ),
      );

      expect(provider.selectedItem, items.last);
      expect(notifications, 1);
      provider.dispose();
    });

    test(
      'compacts while scrolling and expands when a destination is selected',
      () {
        final provider = BottomNavigationProvider(items);
        var notifications = 0;
        provider.addListener(() => notifications++);

        provider.setCompact(true);
        provider.setCompact(true);

        expect(provider.isCompact, isTrue);
        expect(notifications, 1);

        provider.selectItem(items.first);

        expect(provider.isCompact, isFalse);
        expect(notifications, 2);
        provider.dispose();
      },
    );
  });
}
