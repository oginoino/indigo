import 'package:flutter_test/flutter_test.dart';
import 'package:indigo/ui/components/post/post_media_load_error.dart';
import 'package:indigo/util/const/app/app_strings.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('keeps the retry target at least 48 dp in compact media', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 120,
              height: 120,
              child: PostMediaLoadError(
                message: AppStrings.imageLoadFailed,
                icon: Icons.broken_image_outlined,
                onRetry: _retry,
              ),
            ),
          ),
        ),
      ),
    );

    final retryButton = find.byType(IconButton);
    expect(tester.getSize(retryButton).width, greaterThanOrEqualTo(48));
    expect(tester.getSize(retryButton).height, greaterThanOrEqualTo(48));
  });
}

void _retry() {}
