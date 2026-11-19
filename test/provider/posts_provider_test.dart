import 'package:flutter_test/flutter_test.dart';
import 'package:indigo/model/post/post.dart';
import 'package:indigo/model/post/post_content.dart';
import 'package:indigo/model/post/post_media.dart';
import 'package:indigo/provider/post/posts_provider.dart';
import 'package:indigo/service/mapper/post_json_mapper.dart';
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

    test(
      'loads long feeds in pages and exposes the end of the queue',
      () async {
        final socialDataService = AssetSocialDataService();
        await socialDataService.load();
        final provider = PostsProvider(
          repository: _FakePostRepository([
            for (var index = 0; index < PostsProvider.pageSize + 1; index++)
              _post(id: 'post-$index'),
          ]),
          socialDataService: socialDataService,
        );

        await provider.load();

        expect(provider.feedPosts, hasLength(PostsProvider.pageSize));
        expect(provider.hasMore, isTrue);

        await provider.loadMore();

        expect(provider.feedPosts, hasLength(PostsProvider.pageSize + 1));
        expect(provider.hasMore, isFalse);
        expect(provider.isLoadingMore, isFalse);

        await provider.load(refresh: true);

        expect(provider.feedPosts, hasLength(PostsProvider.pageSize));
        expect(provider.hasMore, isTrue);
      },
    );

    test('filters posts by hashtag tag and text entity ids', () async {
      final socialDataService = AssetSocialDataService();
      await socialDataService.load();
      final taggedPost = PostJsonMapper.fromJson(
        socialDataService.data.postById('post-river-walk')!,
      );
      final valueOnlyPost = _post(
        id: 'value-only-tag',
        content: PostContent(
          segments: [
            PostTextSegment(
              text: '#diasleves',
              entity: const PostTextEntity(
                type: PostTextEntityType.hashtag,
                value: 'diasleves',
              ),
            ),
          ],
        ),
      );
      final provider = PostsProvider(
        repository: _FakePostRepository([
          taggedPost,
          valueOnlyPost,
          _post(id: 'unrelated'),
        ]),
        socialDataService: socialDataService,
      );

      await provider.load();

      expect(
        provider.postsForHashtag('tag-fotografia').map((post) => post.id),
        ['post-river-walk'],
      );
      expect(
        provider.postsForHashtag('tag-design-movimento').map((post) => post.id),
        ['post-river-walk'],
      );
      expect(
        provider.postsForHashtag('tag-dias-leves').map((post) => post.id),
        ['post-river-walk', 'value-only-tag'],
      );
    });
  });
}

Post _post({
  required String id,
  PostContent? content,
  List<PostMedia> media = const [],
  PostStatus status = PostStatus.published,
  DateTime? expiresAt,
}) => Post(
  id: id,
  authorPartyRoleId: 'role-ana-user',
  content: content ?? PostContent(segments: [PostTextSegment(text: id)]),
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

  @override
  Future<PostPage> loadPostPage({
    bool refresh = false,
    required int offset,
    required int limit,
  }) async {
    final page = posts.skip(offset).take(limit + 1).toList();
    return PostPage(
      posts: page.take(limit).toList(),
      hasMore: page.length > limit,
    );
  }
}
