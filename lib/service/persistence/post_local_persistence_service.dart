import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../util/const/app/app_strings.dart';
import '../social_data_service.dart';

class PostLocalPersistenceService {
  PostLocalPersistenceService(this._preferences);

  static const _postsCacheKey = 'socialPostsCache';
  static const _schemaVersionKey = 'schema_version';
  static const _postsKey = 'posts';

  final SharedPreferences _preferences;

  Future<List<JsonObject>?> loadPosts({required int schemaVersion}) async {
    final cachedJson = _preferences.getString(_postsCacheKey);
    if (cachedJson == null) return null;

    final decoded = jsonDecode(cachedJson);
    if (decoded is! JsonObject) {
      throw const FormatException(AppStrings.invalidSocialPostCache);
    }

    final cachedSchemaVersion = decoded[_schemaVersionKey];
    if (cachedSchemaVersion is! int) {
      throw const FormatException(AppStrings.invalidSocialPostCache);
    }
    if (cachedSchemaVersion != schemaVersion) {
      await clearPosts();
      return null;
    }

    final posts = decoded[_postsKey];
    if (posts is! List) {
      throw const FormatException(AppStrings.invalidSocialPostCache);
    }

    return List.unmodifiable(
      posts.map((post) {
        if (post is! JsonObject) {
          throw const FormatException(AppStrings.invalidSocialPostCache);
        }
        return Map<String, dynamic>.unmodifiable(post);
      }),
    );
  }

  Future<void> savePosts({
    required int schemaVersion,
    required List<JsonObject> posts,
  }) async {
    final saved = await _preferences.setString(
      _postsCacheKey,
      jsonEncode({_schemaVersionKey: schemaVersion, _postsKey: posts}),
    );
    if (!saved) {
      throw StateError(AppStrings.socialPostCacheSaveFailed);
    }
  }

  Future<void> clearPosts() async {
    final removed = await _preferences.remove(_postsCacheKey);
    if (!removed && _preferences.containsKey(_postsCacheKey)) {
      throw StateError(AppStrings.socialPostCacheClearFailed);
    }
  }
}
