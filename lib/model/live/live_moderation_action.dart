enum LiveModerationActionType {
  hideMessage,
  removeMessage,
  pinMessage,
  unpinMessage,
  muteParticipant,
  removeParticipant,
  banParticipant,
}

class LiveModerationAction {
  const LiveModerationAction({
    required this.id,
    required this.liveSessionId,
    required this.actorPartyRoleId,
    required this.type,
    required this.createdAt,
    this.targetPartyRoleId,
    this.targetMessageId,
    this.reason,
    this.expiresAt,
  });

  final String id;
  final String liveSessionId;
  final String actorPartyRoleId;
  final String? targetPartyRoleId;
  final String? targetMessageId;
  final LiveModerationActionType type;
  final String? reason;
  final DateTime createdAt;
  final DateTime? expiresAt;
}
