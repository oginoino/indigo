enum LiveStatus { scheduled, live, ended, cancelled }

enum LiveVisibility { public, followers, community, private }

class LiveSession {
  const LiveSession({
    required this.id,
    required this.hostPartyRoleId,
    required this.title,
    required this.createdAt,
    this.description,
    this.communityId,
    this.status = LiveStatus.scheduled,
    this.visibility = LiveVisibility.public,
    this.scheduledAt,
    this.startedAt,
    this.endedAt,
  });

  final String id;
  final String hostPartyRoleId;
  final String? communityId;
  final String title;
  final String? description;
  final LiveStatus status;
  final LiveVisibility visibility;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
}
