import 'package:flutter_test/flutter_test.dart';
import 'package:indigo/model/post/post.dart';
import 'package:indigo/model/post/post_content.dart';
import 'package:indigo/model/post/post_media.dart';
import 'package:indigo/provider/post/posts_provider.dart';
import 'package:indigo/service/post_repository.dart';
import 'package:indigo/service/social_data_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PostsProvider', () {
    test(
      'exposes published posts and only video media for the video feed',
      () async {
        final socialDataService = AssetSocialDataService();
        await socialDataService.load();
        final provider = PostsProvider(
          repository: _FakePostRepository([
            _post(
              id: 'image-post',
              media: const [
                PostMedia(
                  id: 'image',
                  type: PostMediaType.image,
                  sourceUrl: 'image.jpg',
                ),
              ],
            ),
            _post(
              id: 'mixed-post',
              media: const [
                PostMedia(
                  id: 'image-2',
                  type: PostMediaType.image,
                  sourceUrl: 'image.jpg',
                ),
                PostMedia(
                  id: 'video',
                  type: PostMediaType.video,
                  sourceUrl: 'video.mp4',
                ),
              ],
            ),
            _post(id: 'draft-post', status: PostStatus.draft),
            _post(id: 'expired-post', expiresAt: DateTime.utc(2025)),
          ]),
          socialDataService: socialDataService,
          clock: () => DateTime.utc(2026),
        );

        await provider.load();

        expect(provider.feedPosts.map((post) => post.id), [
          'image-post',
          'mixed-post',
        ]);
        expect(provider.videoFeedItems, hasLength(1));
        expect(provider.videoFeedItems.single.post.id, 'mixed-post');
        expect(provider.videoFeedItems.single.media.isVideo, isTrue);
        expect(provider.status, PostsLoadStatus.loaded);
        expect(
          provider.authorFor(provider.feedPosts.first)?.displayName,
          'Ana Costa',
        );
      },
    );
  });
}

Post _post({
  required String id,
  List<PostMedia> media = const [],
  PostStatus status = PostStatus.published,
  DateTime? expiresAt,
}) => Post(
  id: id,
  authorPartyRoleId: 'role-ana-user',
  content: PostContent(segments: [PostTextSegment(text: id)]),
  media: media,
  status: status,
  createdAt: DateTime.utc(2026),
  expiresAt: expiresAt,
);

class _FakePostRepository implements PostRepository {
  const _FakePostRepository(this.posts);

  final List<Post> posts;

  @override
  Future<List<Post>> loadPosts({bool refresh = false}) async => posts;
}
