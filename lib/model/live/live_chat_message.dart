import '../post/post_content.dart';

enum LiveChatMessageStatus { visible, hidden, removed }

class LiveChatMessage {
  const LiveChatMessage({
    required this.id,
    required this.liveSessionId,
    required this.authorPartyRoleId,
    required this.content,
    required this.createdAt,
    this.replyToMessageId,
    this.status = LiveChatMessageStatus.visible,
  });

  final String id;
  final String liveSessionId;
  final String authorPartyRoleId;
  final String? replyToMessageId;
  final PostContent content;
  final DateTime createdAt;
  final LiveChatMessageStatus status;
}
