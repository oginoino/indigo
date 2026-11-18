enum ConversationType { direct, group }

class Conversation {
  const Conversation({
    required this.id,
    required this.type,
    required this.createdByPartyRoleId,
    required this.createdAt,
  });

  final String id;
  final ConversationType type;
  final String createdByPartyRoleId;
  final DateTime createdAt;
}
