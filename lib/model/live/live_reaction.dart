enum LiveReactionType { heart, clap, laugh, wow, fire, sad }

class LiveReaction {
  const LiveReaction({
    required this.id,
    required this.liveSessionId,
    required this.actorPartyRoleId,
    required this.type,
    required this.createdAt,
    this.targetPartyRoleId,
  });

  final String id;
  final String liveSessionId;
  final String actorPartyRoleId;
  final String? targetPartyRoleId;
  final LiveReactionType type;
  final DateTime createdAt;
}
