import 'package:flutter/foundation.dart';

import '../../model/party/user_profile.dart';
import '../../model/post/post.dart';
import '../../model/post/post_content.dart';
import '../../model/post/post_media.dart';
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
  static const int pageSize = 20;

  PostsProvider({
    required this._repository,
    required this._socialDataService,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final PostRepository _repository;
  final SocialDataService _socialDataService;
  final DateTime Function() _clock;
  final Map<String, UserProfile> _authorCache = {};
  List<Post> _posts = const [];
  PostsLoadStatus _status = PostsLoadStatus.initial;
  Object? _error;
  Object? _loadMoreError;
  bool _hasMore = true;
  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  Future<void>? _pendingLoad;
  Future<void>? _pendingLoadMore;

  List<Post> get posts => _posts;
  PostsLoadStatus get status => _status;
  Object? get error => _error;
  Object? get loadMoreError => _loadMoreError;
  bool get hasMore => _hasMore;
  bool get isRefreshing => _isRefreshing;
  bool get isLoadingMore => _isLoadingMore;

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

  List<Post> get feedPosts => List.unmodifiable(
    _posts.where((post) => !post.isEphemeral && post.isPublishedAt(_clock())),
  );

  List<Post> get stories => List.unmodifiable(
    _posts.where((post) => post.isEphemeral && post.isPublishedAt(_clock())),
  );

  List<Post> postsForFeed(String feedRoute) => List.unmodifiable(
    feedPosts.where((post) => post.feeds.contains(feedRoute)),
  );

  List<Post> postsForHashtag(String hashtagId) {
    final label = _socialDataService.data.hashtagById(hashtagId)?['label'];
    return List.unmodifiable(
      feedPosts.where(
        (post) =>
            post.tags.any((tag) => tag.id == hashtagId) ||
            post.content.segments.any((segment) {
              final entity = segment.entity;
              return entity?.type == PostTextEntityType.hashtag &&
                  (entity?.id == hashtagId ||
                      (entity?.id == null && entity?.value == label));
            }),
      ),
    );
  }

  List<VideoFeedItem> get videoFeedItems => List.unmodifiable([
    for (final post in feedPosts)
      for (final media in post.media)
        if (media.isVideo) VideoFeedItem(post: post, media: media),
  ]);

  Future<void> load({bool refresh = false}) async {
    if (refresh && _pendingLoadMore != null) {
      await _pendingLoadMore;
    }

    final pendingLoad = _pendingLoad;
    if (pendingLoad != null) {
      await pendingLoad;
      if (!refresh) return;
    }

    final operation = _load(refresh: refresh);
    _pendingLoad = operation;
    try {
      await operation;
    } finally {
      if (identical(_pendingLoad, operation)) _pendingLoad = null;
    }
  }

  Future<void> _load({required bool refresh}) async {
    final hadPosts = _posts.isNotEmpty;
    if (!hadPosts && !refresh) _status = PostsLoadStatus.loading;
    if (refresh) _isRefreshing = true;
    _error = null;
    if (refresh) _loadMoreError = null;
    notifyListeners();

    try {
      final page = await _loadVisiblePage(refresh: refresh, offset: 0);
      _posts = page.posts;
      _hasMore = page.hasMore;
      _status = PostsLoadStatus.loaded;
    } catch (error) {
      _error = error;
      if (!hadPosts) _status = PostsLoadStatus.error;
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_pendingLoad != null ||
        _pendingLoadMore != null ||
        !_hasMore ||
        _status != PostsLoadStatus.loaded) {
      return;
    }

    final operation = _loadMore();
    _pendingLoadMore = operation;
    try {
      await operation;
    } finally {
      if (identical(_pendingLoadMore, operation)) _pendingLoadMore = null;
    }
  }

  Future<void> _loadMore() async {
    _isLoadingMore = true;
    _loadMoreError = null;
    notifyListeners();

    try {
      final page = await _loadVisiblePage(
        refresh: false,
        offset: _posts.length,
      );
      _posts = List.unmodifiable([..._posts, ...page.posts]);
      _hasMore = page.hasMore;
    } catch (error) {
      _loadMoreError = error;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<PostPage> _loadVisiblePage({
    required bool refresh,
    required int offset,
  }) async {
    final posts = <Post>[];
    var hasMore = true;

    while (hasMore && !posts.any((post) => post.isPublishedAt(_clock()))) {
      final page = await _repository.loadPostPage(
        refresh: refresh && posts.isEmpty,
        offset: offset + posts.length,
        limit: pageSize,
      );
      posts.addAll(page.posts);
      hasMore = page.hasMore;
    }

    return PostPage(posts: posts, hasMore: hasMore);
  }
}
