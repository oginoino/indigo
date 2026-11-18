import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:indigo/service/persistence/avatar_image_service.dart';
import 'package:indigo/ui/components/avatar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders its configured size and badge', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final service = AvatarImageService(
      preferences: await SharedPreferences.getInstance(),
      storageDirectory: Directory.systemTemp,
    );

    await tester.pumpWidget(
      Provider<AvatarImageService>.value(
        value: service,
        child: const MaterialApp(
          home: Scaffold(
            body: Avatar(
              size: AvatarSize.small,
              badge: Text('2'),
              decoration: BoxDecoration(color: Colors.blue),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(Avatar)), const Size(32, 32));
    expect(find.text('2'), findsOneWidget);
  });
}
