sealed class PostInteraction {
  const PostInteraction({
    required this.id,
    required this.actorPartyRoleId,
    required this.createdAt,
  });

  final String id;
  final String actorPartyRoleId;
  final DateTime createdAt;
}

enum PostReactionType { like, love, laugh, wow, support, sad, angry }

class PostReaction extends PostInteraction {
  const PostReaction({
    required super.id,
    required super.actorPartyRoleId,
    required super.createdAt,
    required this.postId,
    required this.type,
    this.removedAt,
  });

  final String postId;
  final PostReactionType type;
  final DateTime? removedAt;

  bool get isActive => removedAt == null;
}

class CommentReaction extends PostInteraction {
  const CommentReaction({
    required super.id,
    required super.actorPartyRoleId,
    required super.createdAt,
    required this.commentId,
    required this.type,
    this.removedAt,
  });

  final String commentId;
  final PostReactionType type;
  final DateTime? removedAt;

  bool get isActive => removedAt == null;
}

class PostSave extends PostInteraction {
  const PostSave({
    required super.id,
    required super.actorPartyRoleId,
    required super.createdAt,
    required this.postId,
    this.removedAt,
  });

  final String postId;
  final DateTime? removedAt;

  bool get isActive => removedAt == null;
}

enum PostShareDestination { feed, conversation }

class PostShare extends PostInteraction {
  const PostShare.toFeed({
    required super.id,
    required super.actorPartyRoleId,
    required super.createdAt,
    required this.postId,
    this.responsePostId,
  }) : destination = PostShareDestination.feed,
       conversationId = null,
       responseMessageId = null;

  const PostShare.toConversation({
    required super.id,
    required super.actorPartyRoleId,
    required super.createdAt,
    required this.postId,
    required this.conversationId,
    this.responseMessageId,
  }) : destination = PostShareDestination.conversation,
       responsePostId = null;

  final String postId;
  final PostShareDestination destination;
  final String? conversationId;
  final String? responsePostId;
  final String? responseMessageId;
}
