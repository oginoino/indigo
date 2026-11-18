import 'post_content.dart';
import 'post_engagement_summary.dart';
import 'post_media.dart';

class PostComment {
  PostComment({
    required this.id,
    required this.postId,
    required this.authorPartyRoleId,
    required this.content,
    required this.createdAt,
    List<PostMedia> media = const [],
    this.engagement = const CommentEngagementSummary(),
    this.parentCommentId,
  }) : media = List.unmodifiable(media);

  final String id;
  final String postId;
  final String? parentCommentId;
  final String authorPartyRoleId;
  final PostContent content;
  final List<PostMedia> media;
  final CommentEngagementSummary engagement;
  final DateTime createdAt;

  bool get isReply => parentCommentId != null;
}
