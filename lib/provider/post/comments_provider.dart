import 'package:flutter/foundation.dart';

import '../../model/party/user_profile.dart';
import '../../model/post/post_comment.dart';
import '../../service/mapper/comment_json_mapper.dart';
import '../../service/mapper/user_profile_json_mapper.dart';
import '../../service/social_data_service.dart';

/// Estado de carregamento de comentários de um post.
enum CommentsLoadStatus { initial, loading, loaded, error }

/// Provider responsável por carregar, cachear e gerenciar a interação com
/// comentários de um post.
///
/// Mantém:
/// - [_commentsByPost]: comentários já carregados, indexados por [postId].
/// - [_expandedReplies]: IDs de comentários cujas respostas estão visíveis.
/// - [_replyingToCommentId]: ID do comentário sendo respondido (ou null).
class CommentsProvider extends ChangeNotifier {
  CommentsProvider({required this._socialDataService});

  final SocialDataService _socialDataService;

  /// Comentários carregados, agrupados por postId.
  final Map<String, List<PostComment>> _commentsByPost = {};

  /// Status de carregamento por postId.
  final Map<String, CommentsLoadStatus> _statusByPost = {};

  /// Erros de carregamento por postId.
  final Map<String, Object> _errorByPost = {};

  /// IDs de comentários com respostas expandidas.
  final Set<String> _expandedReplies = {};

  /// ID do comentário sendo respondido (null = nenhum).
  String? _replyingToCommentId;

  /// Cache de perfis de autores resolvidos a partir do [SocialDataService].
  final Map<String, UserProfile> _authorCache = {};

  // ---- Consultas públicas ---------------------------------------------------

  /// Status de carregamento de um post.
  CommentsLoadStatus statusFor(String postId) =>
      _statusByPost[postId] ?? CommentsLoadStatus.initial;

  /// Erro de carregamento de um post (null se não houve erro).
  Object? errorFor(String postId) => _errorByPost[postId];

  /// Comentários de nível raiz (não são respostas) de um [postId].
  List<PostComment> topLevelFor(String postId) {
    final all = _commentsByPost[postId] ?? const [];
    return List.unmodifiable(
      all.where((c) => c.parentCommentId == null),
    );
  }

  /// Respostas de um [commentId] específico.
  List<PostComment> repliesFor(String commentId) {
    // Respostas pertencem ao mesmo postId — buscamos em todos os comentários.
    for (final comments in _commentsByPost.values) {
      final replies = comments
          .where((c) => c.parentCommentId == commentId)
          .toList(growable: false);
      if (replies.isNotEmpty) return List.unmodifiable(replies);
    }
    return const [];
  }

  /// Indica se as respostas do [commentId] estão visíveis.
  bool areRepliesExpanded(String commentId) =>
      _expandedReplies.contains(commentId);

  /// Comentário sendo respondido (ou null se nenhum).
  PostComment? get replyingTo {
    final id = _replyingToCommentId;
    if (id == null) return null;
    for (final comments in _commentsByPost.values) {
      for (final c in comments) {
        if (c.id == id) return c;
      }
    }
    return null;
  }

  // ---- Ações públicas -------------------------------------------------------

  /// Carrega os comentários do [postId] caso ainda não tenham sido carregados.
  /// Idempotente: chamadas adicionais enquanto [loaded] são ignoradas.
  void loadForPost(String postId) {
    final status = statusFor(postId);
    if (status == CommentsLoadStatus.loading ||
        status == CommentsLoadStatus.loaded) {
      return;
    }

    _statusByPost[postId] = CommentsLoadStatus.loading;
    _errorByPost.remove(postId);
    notifyListeners();

    try {
      final rawComments =
          _socialDataService.data.commentsForPost(postId);
      final comments = rawComments
          .map(CommentJsonMapper.fromJson)
          .toList(growable: false);
      _commentsByPost[postId] = List.unmodifiable(comments);
      _statusByPost[postId] = CommentsLoadStatus.loaded;
    } catch (error) {
      _errorByPost[postId] = error;
      _statusByPost[postId] = CommentsLoadStatus.error;
    }

    notifyListeners();
  }

  /// Alterna a visibilidade das respostas de um comentário.
  void toggleReplies(String commentId) {
    if (_expandedReplies.contains(commentId)) {
      _expandedReplies.remove(commentId);
    } else {
      _expandedReplies.add(commentId);
    }
    notifyListeners();
  }

  /// Define o comentário sendo respondido (null para cancelar).
  void setReplyingTo(String? commentId) {
    if (_replyingToCommentId == commentId) return;
    _replyingToCommentId = commentId;
    notifyListeners();
  }

  /// Resolve o [UserProfile] do autor de um [comment].
  /// Resultado é armazenado em cache para evitar lookups repetidos.
  UserProfile? authorFor(PostComment comment) {
    final roleId = comment.authorPartyRoleId;
    final cached = _authorCache[roleId];
    if (cached != null) return cached;

    final profileJson =
        _socialDataService.data.profileForPartyRole(roleId);
    if (profileJson == null) return null;

    final profile = UserProfileJsonMapper.fromJson(profileJson);
    _authorCache[roleId] = profile;
    return profile;
  }
}
