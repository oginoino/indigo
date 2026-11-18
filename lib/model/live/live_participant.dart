enum LiveParticipantStatus { connected, disconnected, left, removed }

class LiveParticipant {
  const LiveParticipant({
    required this.id,
    required this.liveSessionId,
    required this.partyRoleId,
    required this.joinedAt,
    this.leftAt,
    this.status = LiveParticipantStatus.connected,
  });

  final String id;
  final String liveSessionId;
  final String partyRoleId;
  final DateTime joinedAt;
  final DateTime? leftAt;
  final LiveParticipantStatus status;

  bool get isConnected => status == LiveParticipantStatus.connected;
}
