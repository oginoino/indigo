import 'package:flutter/foundation.dart';

import '../../model/post/post.dart';
import '../../model/post/post_media.dart';
import '../../model/party/user_profile.dart';
import '../../service/mapper/user_profile_json_mapper.dart';
import '../../service/post_repository.dart';
import '../../service/social_data_service.dart';

enum PostsLoadStatus { initial, loading, loaded, error }

class VideoFeedItem {
  const VideoFeedItem({required this.post, required this.media});

  final Post post;
  final PostMedia media;
}

class PostsProvider extends ChangeNotifier {
  PostsProvider({
    required PostRepository repository,
    required SocialDataService socialDataService,
    DateTime Function()? clock,
  }) : _repository = repository,
       _socialDataService = socialDataService,
       _clock = clock ?? DateTime.now;

  final PostRepository _repository;
  final SocialDataService _socialDataService;
  final DateTime Function() _clock;
  final Map<String, UserProfile> _authorCache = {};
  List<Post> _posts = const [];
  PostsLoadStatus _status = PostsLoadStatus.initial;
  Object? _error;
  Future<void>? _pendingLoad;

  List<Post> get posts => _posts;
  PostsLoadStatus get status => _status;
  Object? get error => _error;

  UserProfile? authorFor(Post post) {
    final roleId = post.authorPartyRoleId;
    final cachedProfile = _authorCache[roleId];
    if (cachedProfile != null) return cachedProfile;

    final profileJson = _socialDataService.data.profileForPartyRole(roleId);
    if (profileJson == null) return null;

    final profile = UserProfileJsonMapper.fromJson(profileJson);
    _authorCache[roleId] = profile;
    return profile;
  }

  List<Post> get feedPosts =>
      List.unmodifiable(_posts.where((post) => post.isPublishedAt(_clock())));

  List<VideoFeedItem> get videoFeedItems => List.unmodifiable([
    for (final post in feedPosts)
      for (final media in post.media)
        if (media.isVideo) VideoFeedItem(post: post, media: media),
  ]);

  Future<void> load({bool refresh = false}) {
    if (_pendingLoad != null) return _pendingLoad!;
    return _pendingLoad = _load(refresh: refresh);
  }

  Future<void> _load({required bool refresh}) async {
    _status = PostsLoadStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _posts = await _repository.loadPosts(refresh: refresh);
      _status = PostsLoadStatus.loaded;
    } catch (error) {
      _error = error;
      _status = PostsLoadStatus.error;
    } finally {
      _pendingLoad = null;
      notifyListeners();
    }
  }
}
