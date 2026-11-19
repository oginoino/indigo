import 'package:flutter_test/flutter_test.dart';
import 'package:indigo/ui/components/avatar.dart';
import 'package:indigo/ui/components/avatar_group.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders every member while within the visible limit', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AvatarGroup(
            members: [
              AvatarGroupMember(),
              AvatarGroupMember(),
              AvatarGroupMember(),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Avatar), findsNWidgets(3));
  });

  testWidgets('collapses extra members into an overflow counter', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AvatarGroup(
            maxVisible: 3,
            members: [
              AvatarGroupMember(),
              AvatarGroupMember(),
              AvatarGroupMember(),
              AvatarGroupMember(),
              AvatarGroupMember(),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Avatar), findsNWidgets(2));
    expect(find.text('+3'), findsOneWidget);
  });

  testWidgets('renders the provided empty state when there are no members', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AvatarGroup(members: [], emptyState: Text('empty')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('empty'), findsOneWidget);
    expect(find.byType(Avatar), findsNothing);
  });
}
