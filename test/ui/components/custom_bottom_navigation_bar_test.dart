import 'package:flutter_test/flutter_test.dart';
import 'package:indigo/ui/components/custom_bottom_navigation_bar.dart';
import 'package:indigo/ui/theme/app_theme.dart';
import 'package:indigo/util/const/ui/ui_constants.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('keeps the translucent navigation usable in both themes', (
    tester,
  ) async {
    for (final theme in [lightTheme, darkTheme]) {
      var selectedIndex = -1;

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            bottomNavigationBar: CustomBottomNavigationBar(
              currentIndex: 0,
              onTap: (index) => selectedIndex = index,
              items: const [
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
              ],
            ),
          ),
        ),
      );

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
              items: const [
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
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final compactSurface = find.descendant(
        of: find.byType(CustomBottomNavigationBar),
        matching: find.byType(ClipRRect),
      );
      expect(
        tester.getSize(compactSurface).height,
        UIConstants.bottomNavigationCompactHeight,
      );
    }
  });
}
