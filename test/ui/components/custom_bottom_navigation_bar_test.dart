import 'package:flutter_test/flutter_test.dart';
import 'package:indigo/ui/components/custom_bottom_navigation_bar.dart';
import 'package:indigo/ui/theme/app_theme.dart';
import 'package:indigo/util/const/ui/ui_constants.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('compacts in both dimensions and remains usable in both themes', (
    tester,
  ) async {
    for (final theme in [lightTheme, darkTheme]) {
      var selectedIndex = 0;
      final items = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Início',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            bottomNavigationBar: CustomBottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: (index) => selectedIndex = index,
              items: items,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final surface = find.descendant(
        of: find.byType(CustomBottomNavigationBar),
        matching: find.byType(ClipRRect),
      );
      final expandedSize = tester.getSize(surface);
      final containers = find.descendant(
        of: find.byType(CustomBottomNavigationBar),
        matching: find.byType(Container),
      );
      final background =
          tester.widget<Container>(containers.last).decoration!
              as BoxDecoration;

      expect(background.color!.a, lessThan(1));
      await tester.tap(find.byTooltip('Perfil'));
      await tester.pumpAndSettle();
      expect(selectedIndex, 1);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            bottomNavigationBar: CustomBottomNavigationBar(
              compact: true,
              currentIndex: selectedIndex,
              onTap: (index) => selectedIndex = index,
              items: items,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final compactSize = tester.getSize(surface);
      expect(compactSize.height, UIConstants.bottomNavigationCompactHeight);
      expect(compactSize.width, lessThan(expandedSize.width));

      await tester.tap(find.byTooltip('Início'));
      await tester.pumpAndSettle();
      expect(selectedIndex, 0);
    }
  });
}
