import 'post_interaction.dart';

class PostViewerEngagement {
  const PostViewerEngagement({
    this.reaction,
    this.isSaved = false,
    this.isShared = false,
  });

  final PostReactionType? reaction;
  final bool isSaved;
  final bool isShared;

  bool get isReacted => reaction != null;
}

class PostEngagementSummary {
  const PostEngagementSummary({
    this.reactionCount = 0,
    this.commentCount = 0,
    this.saveCount = 0,
    this.shareCount = 0,
    this.viewCount = 0,
    this.viewer = const PostViewerEngagement(),
  });

  final int reactionCount;
  final int commentCount;
  final int saveCount;
  final int shareCount;
  final int viewCount;
  final PostViewerEngagement viewer;
}

class CommentEngagementSummary {
  const CommentEngagementSummary({
    this.reactionCount = 0,
    this.replyCount = 0,
    this.viewerReaction,
  });

  final int reactionCount;
  final int replyCount;
  final PostReactionType? viewerReaction;
}
