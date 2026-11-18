import 'post_interaction.dart';

class PostViewerEngagement {
  static const bool defaultIsSaved = false;
  static const bool defaultIsShared = false;

  const PostViewerEngagement({
    this.reaction,
    this.isSaved = defaultIsSaved,
    this.isShared = defaultIsShared,
  });

  final PostReactionType? reaction;
  final bool isSaved;
  final bool isShared;

  bool get isReacted => reaction != null;
}

class PostEngagementSummary {
  static const int defaultCount = 0;

  const PostEngagementSummary({
    this.reactionCount = defaultCount,
    this.commentCount = defaultCount,
    this.saveCount = defaultCount,
    this.shareCount = defaultCount,
    this.viewCount = defaultCount,
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
