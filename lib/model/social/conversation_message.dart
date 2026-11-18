import '../post/post_content.dart';
import '../post/post_media.dart';

class ConversationMessage {
  ConversationMessage({
    required this.id,
    required this.conversationId,
    required this.senderPartyRoleId,
    required this.content,
    required this.createdAt,
    List<PostMedia> media = const [],
    this.sharedPostId,
    this.replyToMessageId,
    this.editedAt,
  }) : media = List.unmodifiable(media);

  final String id;
  final String conversationId;
  final String senderPartyRoleId;
  final PostContent content;
  final List<PostMedia> media;
  final String? sharedPostId;
  final String? replyToMessageId;
  final DateTime createdAt;
  final DateTime? editedAt;
}
