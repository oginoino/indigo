import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indigo/model/post/post_media.dart';
import 'package:indigo/ui/components/post/post_media_gallery.dart';

void main() {
  group('PostMediaGallery', () {
    testWidgets('opens a swipeable fullscreen viewer at the selected image', (
      tester,
    ) async {
      await tester.pumpWidget(_galleryApp(_photos(3)));

      await tester.tap(find.byTooltip('Visualizar imagem 2'));
      await tester.pumpAndSettle();

      expect(find.text('2 / 3'), findsOneWidget);

      await tester.drag(find.byType(PageView), const Offset(-700, 0));
      await tester.pumpAndSettle();

      expect(find.text('3 / 3'), findsOneWidget);

      await tester.tap(find.byTooltip('Fechar visualização'));
      await tester.pumpAndSettle();

      expect(find.text('3 / 3'), findsNothing);
    });

    testWidgets('shows an overflow count after the four-tile grid limit', (
      tester,
    ) async {
      await tester.pumpWidget(_galleryApp(_photos(5)));

      expect(find.text('+1'), findsOneWidget);
    });
  });
}

Widget _galleryApp(List<PostMedia> media) => MaterialApp(
  home: Scaffold(
    body: Center(
      child: SizedBox(
        width: 320,
        child: PostMediaGallery(postId: 'post-gallery', media: media),
      ),
    ),
  ),
);

List<PostMedia> _photos(int count) => List.generate(
  count,
  (index) => PostMedia(
    id: 'photo-$index',
    type: PostMediaType.image,
    sourceUrl: 'https://example.test/photo-$index.jpg',
  ),
);
