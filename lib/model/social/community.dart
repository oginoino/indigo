enum CommunityVisibility { public, private, hidden }

class Community {
  const Community({
    required this.id,
    required this.name,
    required this.createdByPartyRoleId,
    required this.createdAt,
    this.description,
    this.visibility = CommunityVisibility.public,
  });

  final String id;
  final String name;
  final String? description;
  final String createdByPartyRoleId;
  final DateTime createdAt;
  final CommunityVisibility visibility;
}
