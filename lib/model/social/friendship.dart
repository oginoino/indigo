enum FriendshipStatus { pending, accepted, rejected, blocked }

class Friendship {
  const Friendship({
    required this.id,
    required this.requesterPartyId,
    required this.recipientPartyId,
    required this.status,
    required this.requestedAt,
    this.respondedAt,
  });

  final String id;
  final String requesterPartyId;
  final String recipientPartyId;
  final FriendshipStatus status;
  final DateTime requestedAt;
  final DateTime? respondedAt;
}
