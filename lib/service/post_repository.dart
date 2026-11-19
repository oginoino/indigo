import '../model/post/post.dart';
import 'mapper/post_json_mapper.dart';
import 'persistence/post_local_persistence_service.dart';
import 'social_data_service.dart';

abstract interface class PostRepository {
  Future<List<Post>> loadPosts({bool refresh = false});

  Future<PostPage> loadPostPage({
    bool refresh = false,
    required int offset,
    required int limit,
  });
}

class PostPage {
  PostPage({required List<Post> posts, required this.hasMore})
    : posts = List.unmodifiable(posts);

  final List<Post> posts;
  final bool hasMore;
}

class AssetPostRepository implements PostRepository {
  const AssetPostRepository({
    required SocialDataService socialDataService,
    required PostLocalPersistenceService localPersistence,
  }) : _socialDataService = socialDataService,
       _localPersistence = localPersistence;

  final SocialDataService _socialDataService;
  final PostLocalPersistenceService _localPersistence;

  @override
  Future<List<Post>> loadPosts({bool refresh = false}) async {
    final records = await _loadRecords(refresh: refresh);
    return List.unmodifiable(records.map(PostJsonMapper.fromJson));
  }

  @override
  Future<PostPage> loadPostPage({
    bool refresh = false,
    required int offset,
    required int limit,
  }) async {
    if (offset < 0) {
      throw ArgumentError.value(offset, 'offset', 'Must be non-negative');
    }
    if (limit <= 0) {
      throw ArgumentError.value(limit, 'limit', 'Must be greater than zero');
    }

    final records = await _loadRecords(refresh: refresh);
    final pageRecords = records.skip(offset).take(limit + 1).toList();
    final hasMore = pageRecords.length > limit;
    final posts = pageRecords
        .take(limit)
        .map(PostJsonMapper.fromJson)
        .toList(growable: false);

    return PostPage(posts: posts, hasMore: hasMore);
  }

  Future<List<Map<String, dynamic>>> _loadRecords({
    required bool refresh,
  }) async {
    final data = _socialDataService.data;
    final cachedPosts = refresh
        ? null
        : await _localPersistence.loadPosts(schemaVersion: data.schemaVersion);
    final records = cachedPosts ?? data.posts;

    if (cachedPosts == null) {
      await _localPersistence.savePosts(
        schemaVersion: data.schemaVersion,
        posts: records,
      );
    }

    return records;
  }
}
