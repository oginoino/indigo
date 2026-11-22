import 'package:flutter/foundation.dart';

import '../../model/party/user_profile.dart';
import '../../model/post/post.dart';
import '../../model/post/post_content.dart';
import '../../model/post/post_engagement_summary.dart';
import '../../model/post/post_interaction.dart';
import '../../model/post/post_media.dart';
import '../../service/mapper/user_profile_json_mapper.dart';
import '../../service/post_repository.dart';
import '../../service/social_data_service.dart';
import '../../util/const/app/social_data_constants.dart';
import '../create/create_post_provider.dart';

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
  })  : _clock = clock ?? DateTime.now,
        _currentUserRoleId =
            _resolveCurrentUserRoleId(_socialDataService);

  final PostRepository _repository;
  final SocialDataService _socialDataService;
  final DateTime Function() _clock;
  final String? _currentUserRoleId;
  final Map<String, UserProfile> _authorCache = {};

  static String? _resolveCurrentUserRoleId(SocialDataService service) {
    try {
      final data = service.data;
      final partyId = data.currentUserPartyId;
      final profileJson = data.profileForParty(partyId);
      if (profileJson == null) return null;
      return profileJson[SocialDataConstants.platformUserRoleIdKey] as String?;
    } catch (_) {
      return null;
    }
  }

  String? get currentUserRoleId => _currentUserRoleId;

  /// Overrides de engagement aplicados otimisticamente (antes de confirmação
  /// do servidor). Indexados por post ID.
  final Map<String, PostEngagementSummary> _engagementOverrides = {};

  List<Post> _posts = const [];
  /// Posts criados localmente (publicação otimista) ainda não confirmados
  /// pelo servidor. Preservados entre reloads e merged na frente do feed.
  final List<Post> _localPosts = [];
  List<Post> _remotePosts = const [];
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

  /// Retorna o engagement efetivo de um post, considerando overrides otimistas.
  PostEngagementSummary engagementFor(Post post) =>
      _engagementOverrides[post.id] ?? post.engagement;

  UserProfile? authorFor(Post post) {
    final roleId = post.authorPartyRoleId;
    // Posts locais publicados na sessão atual: resolve via currentUserRoleId.
    final effectiveRoleId = roleId == CreatePostProvider.kLocalAuthorRoleId
        ? (_currentUserRoleId ?? roleId)
        : roleId;

    final cachedProfile = _authorCache[effectiveRoleId];
    if (cachedProfile != null) return cachedProfile;

    final profileJson =
        _socialDataService.data.profileForPartyRole(effectiveRoleId);
    if (profileJson == null) return null;

    final profile = UserProfileJsonMapper.fromJson(profileJson);
    _authorCache[effectiveRoleId] = profile;
    return profile;
  }

  List<Post> get feedPosts => List.unmodifiable(
    _posts.where((post) => !post.isEphemeral && post.isPublishedAt(_clock())),
  );

  /// Insere um post criado localmente no início do feed (antes de confirmação
  /// do servidor). Invalida o cache de vídeos e notifica os ouvintes.
  void addLocalPost(Post post) {
    // Substitui o roleId sentinela pelo roleId real do usuário corrente.
    final roleId = _currentUserRoleId;
    final corrected =
        post.authorPartyRoleId == CreatePostProvider.kLocalAuthorRoleId &&
                roleId != null
            ? Post(
                id: post.id,
                authorPartyRoleId: roleId,
                content: post.content,
                title: post.title,
                media: post.media,
                feeds: post.feeds,
                status: post.status,
                createdAt: post.createdAt,
                expiresAt: post.expiresAt,
              )
            : post;
    _localPosts.insert(0, corrected);
    _rebuildPosts();
  }

  /// Reconstrói `_posts` juntando posts locais (frente) + posts remotos.
  void _rebuildPosts() {
    _posts = List.unmodifiable([..._localPosts, ..._remotePosts]);
    notifyListeners();
  }

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

  List<VideoFeedItem>? _videoFeedItemsCache;

  List<VideoFeedItem> get videoFeedItems =>
      _videoFeedItemsCache ??= List.unmodifiable([
        for (final post in feedPosts)
          for (final media in post.media)
            if (media.isVideo) VideoFeedItem(post: post, media: media),
      ]);

  @override
  void notifyListeners() {
    _videoFeedItemsCache = null;
    super.notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Interações otimistas
  // ---------------------------------------------------------------------------

  /// Alterna curtida do [post]. Aplica imediatamente na UI; reversível se o
  /// servidor rejeitar (implementação futura).
  void toggleLike(Post post) {
    final current = engagementFor(post);
    final wasLiked = current.viewer.isReacted;
    _engagementOverrides[post.id] = PostEngagementSummary(
      reactionCount: wasLiked
          ? (current.reactionCount - 1).clamp(0, double.maxFinite.toInt())
          : current.reactionCount + 1,
      commentCount: current.commentCount,
      saveCount: current.saveCount,
      shareCount: current.shareCount,
      viewCount: current.viewCount,
      viewer: PostViewerEngagement(
        reaction: wasLiked ? null : PostReactionType.like,
        isSaved: current.viewer.isSaved,
        isShared: current.viewer.isShared,
      ),
    );
    notifyListeners();
  }

  /// Alterna salvamento do [post].
  void toggleSave(Post post) {
    final current = engagementFor(post);
    final wasSaved = current.viewer.isSaved;
    _engagementOverrides[post.id] = PostEngagementSummary(
      reactionCount: current.reactionCount,
      commentCount: current.commentCount,
      saveCount: wasSaved
          ? (current.saveCount - 1).clamp(0, double.maxFinite.toInt())
          : current.saveCount + 1,
      shareCount: current.shareCount,
      viewCount: current.viewCount,
      viewer: PostViewerEngagement(
        reaction: current.viewer.reaction,
        isSaved: !wasSaved,
        isShared: current.viewer.isShared,
      ),
    );
    notifyListeners();
  }

  /// Alterna republicação do [post].
  void toggleRepost(Post post) {
    final current = engagementFor(post);
    final wasShared = current.viewer.isShared;
    _engagementOverrides[post.id] = PostEngagementSummary(
      reactionCount: current.reactionCount,
      commentCount: current.commentCount,
      saveCount: current.saveCount,
      shareCount: wasShared
          ? (current.shareCount - 1).clamp(0, double.maxFinite.toInt())
          : current.shareCount + 1,
      viewCount: current.viewCount,
      viewer: PostViewerEngagement(
        reaction: current.viewer.reaction,
        isSaved: current.viewer.isSaved,
        isShared: !wasShared,
      ),
    );
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Carregamento
  // ---------------------------------------------------------------------------

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
      _remotePosts = page.posts;
      _rebuildPosts();
      _hasMore = page.hasMore;
      _status = PostsLoadStatus.loaded;
      // Warm-up do cache de autores dos primeiros posts em paralelo — evita
      // jank no primeiro scroll enquanto os perfis são resolvidos um a um.
      _warmUpAuthorCache(page.posts);
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
        offset: _remotePosts.length,
      );
      _remotePosts = List.unmodifiable([..._remotePosts, ...page.posts]);
      _rebuildPosts();
      _hasMore = page.hasMore;
    } catch (error) {
      _loadMoreError = error;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Preenche o cache de autores para os primeiros [_kAuthorPrefetchCount]
  /// posts em paralelo, eliminando lookups sequenciais no primeiro render.
  ///
  /// Opera de forma síncrona (os dados vêm do [SocialDataService] local), mas
  /// agrupamos os IDs únicos para evitar trabalho duplicado.
  void _warmUpAuthorCache(List<Post> posts) {
    final uniqueRoleIds = posts
        .take(_kAuthorPrefetchCount)
        .map((p) => p.authorPartyRoleId)
        .toSet();
    for (final roleId in uniqueRoleIds) {
      if (_authorCache.containsKey(roleId)) continue;
      final profileJson = _socialDataService.data.profileForPartyRole(roleId);
      if (profileJson == null) continue;
      _authorCache[roleId] = UserProfileJsonMapper.fromJson(profileJson);
    }
  }

  /// Número de autores pré-carregados no cache após o primeiro load.
  static const int _kAuthorPrefetchCount = 10;

  Future<PostPage> _loadVisiblePage({
    required bool refresh,
    required int offset,
  }) async {
    final posts = <Post>[];
    var hasMore = true;
    const maxPages = 10;
    var pagesFetched = 0;

    while (hasMore &&
        pagesFetched < maxPages &&
        !posts.any((post) => post.isPublishedAt(_clock()))) {
      final page = await _repository.loadPostPage(
        refresh: refresh && posts.isEmpty,
        offset: offset + posts.length,
        limit: pageSize,
      );
      posts.addAll(page.posts);
      hasMore = page.hasMore;
      pagesFetched++;
    }

    return PostPage(posts: posts, hasMore: hasMore);
  }
}
