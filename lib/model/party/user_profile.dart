class UserProfile {
  const UserProfile({
    required this.partyId,
    required this.platformUserRoleId,
    required this.username,
    required this.displayName,
    required this.createdAt,
    this.avatarUrl,
    this.bio,
  });

  final String partyId;
  final String platformUserRoleId;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final DateTime createdAt;
}
