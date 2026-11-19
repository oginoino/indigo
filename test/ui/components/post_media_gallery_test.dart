import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:indigo/model/party/user_profile.dart';
import 'package:indigo/model/post/post.dart';
import 'package:indigo/model/post/post_content.dart';
import 'package:indigo/model/post/post_engagement_summary.dart';
import 'package:indigo/model/post/post_media.dart';
import 'package:indigo/route/routes.dart';
import 'package:indigo/ui/components/post/post_audio_player.dart';
import 'package:indigo/ui/components/post/post_engagement_bar.dart';
import 'package:indigo/ui/components/post/post_media_gallery.dart';
import 'package:indigo/util/const/app/app_strings.dart';
import 'package:indigo/util/const/ui/ui_constants.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('PostMediaGallery', () {
    testWidgets('opens a swipeable fullscreen viewer at the selected image', (
      tester,
    ) async {
      await tester.pumpWidget(_galleryApp(_photos(3)));

      await tester.tap(find.byTooltip('Visualizar imagem 2'));
      await tester.pumpAndSettle();

      expect(find.text('2 / 3'), findsOneWidget);
      expect(find.text('Ana Costa'), findsOneWidget);
      expect(find.text('@ana.costa'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.byIcon(Icons.mode_comment_outlined), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.repeat), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
      expect(
        tester.widget<PostEngagementBar>(find.byType(PostEngagementBar)).layout,
        PostEngagementLayout.horizontal,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Padding &&
              widget.padding ==
                  const EdgeInsets.fromLTRB(
                    UIConstants.videoOverlayPadding,
                    UIConstants.videoOverlayPadding,
                    UIConstants.fullscreenEngagementRightInset,
                    UIConstants.videoOverlayPadding,
                  ),
        ),
        findsOneWidget,
      );

      await tester.drag(find.byType(PageView), const Offset(-700, 0));
      await tester.pumpAndSettle();

      expect(find.text('3 / 3'), findsOneWidget);

      await tester.tap(find.byTooltip('Fechar visualização'));
      await tester.pumpAndSettle();

      expect(find.text('3 / 3'), findsNothing);
    });

    testWidgets('adapts fullscreen post actions when the device rotates', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(900, 400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_galleryApp(_photos(1)));
      await tester.tap(find.byTooltip('Visualizar imagem 1'));
      await tester.pumpAndSettle();

      expect(
        tester.widget<PostEngagementBar>(find.byType(PostEngagementBar)).layout,
        PostEngagementLayout.horizontal,
      );
      expect(tester.takeException(), isNull);

      tester.view.physicalSize = const Size(400, 900);
      await tester.pumpAndSettle();

      expect(
        tester.widget<PostEngagementBar>(find.byType(PostEngagementBar)).layout,
        PostEngagementLayout.vertical,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows an overflow count after the four-tile grid limit', (
      tester,
    ) async {
      await tester.pumpWidget(_galleryApp(_photos(5)));

      expect(find.text('+1'), findsOneWidget);
    });

    testWidgets('opens the selected post video in the video feed', (
      tester,
    ) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: Center(
                child: SizedBox(
                  width: 320,
                  child: PostMediaGallery(
                    post: Post(
                      id: 'post-video',
                      authorPartyRoleId: 'role-ana-user',
                      content: PostContent(
                        segments: [PostTextSegment(text: 'Video preview')],
                      ),
                      createdAt: DateTime.utc(2026),
                      media: [
                        PostMedia(
                          id: 'media-video',
                          type: PostMediaType.video,
                          sourceUrl: 'https://example.test/video.mp4',
                        ),
                      ],
                    ),
                    author: null,
                  ),
                ),
              ),
            ),
          ),
          GoRoute(
            path: Routes.videos,
            builder: (context, state) => Text(
              '${state.uri.queryParameters[Routes.videoPostIdQueryParameter]}:'
              '${state.uri.queryParameters[Routes.videoMediaIdQueryParameter]}',
            ),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.tap(find.byTooltip(AppStrings.playVideo));
      await tester.pumpAndSettle();

      expect(find.text('post-video:media-video'), findsOneWidget);
    });

    testWidgets('keeps audio out of the photo grid', (tester) async {
      await tester.pumpWidget(
        _galleryApp([
          const PostMedia(
            id: 'photo-a',
            type: PostMediaType.image,
            sourceUrl: 'https://example.test/photo-a.jpg',
          ),
          const PostMedia(
            id: 'audio-1',
            type: PostMediaType.audio,
            sourceUrl: 'https://example.test/note.mp3',
            duration: Duration(seconds: 12),
            waveform: [0.2, 0.8, 0.4],
          ),
          const PostMedia(
            id: 'photo-b',
            type: PostMediaType.image,
            sourceUrl: 'https://example.test/photo-b.jpg',
          ),
        ]),
      );
      await tester.pump();

      expect(find.byType(PostAudioPlayer), findsOneWidget);
      expect(find.text('0:12'), findsOneWidget);
      expect(find.byTooltip('Visualizar imagem 1'), findsOneWidget);
      expect(find.byTooltip('Visualizar imagem 2'), findsOneWidget);
      expect(find.byTooltip('Visualizar imagem 3'), findsNothing);
    });

    testWidgets('offers a retry when a media image fails to load', (
      tester,
    ) async {
      await tester.pumpWidget(_galleryApp(_photos(1)));
      await tester.pumpAndSettle();

      expect(find.byTooltip(AppStrings.retry), findsOneWidget);

      await tester.tap(find.byTooltip(AppStrings.retry));
      await tester.pumpAndSettle();

      expect(find.byTooltip(AppStrings.retry), findsOneWidget);
    });
  });
}

Widget _galleryApp(List<PostMedia> media) => MaterialApp(
  home: Scaffold(
    body: Center(
      child: SizedBox(
        width: 320,
        child: PostMediaGallery(
          post: Post(
            id: 'post-gallery',
            authorPartyRoleId: 'role-ana-user',
            content: PostContent(segments: [PostTextSegment(text: 'Gallery')]),
            createdAt: DateTime.utc(2026),
            engagement: const PostEngagementSummary(
              commentCount: 8,
              reactionCount: 74,
              shareCount: 12,
              saveCount: 4,
            ),
            media: media,
          ),
          author: UserProfile(
            partyId: 'party-ana',
            platformUserRoleId: 'role-ana-user',
            username: 'ana.costa',
            displayName: 'Ana Costa',
            createdAt: DateTime.utc(2024),
          ),
        ),
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
