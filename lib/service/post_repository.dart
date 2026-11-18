import '../model/post/post.dart';
import 'mapper/post_json_mapper.dart';
import 'persistence/post_local_persistence_service.dart';
import 'social_data_service.dart';

abstract interface class PostRepository {
  Future<List<Post>> loadPosts({bool refresh = false});
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

    return List.unmodifiable(records.map(PostJsonMapper.fromJson));
  }
}
