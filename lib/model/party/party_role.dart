enum PartyRoleType {
  platformUser,
  communityOwner,
  communityModerator,
  communityMember,
  conversationParticipant,
  liveHost,
  liveModerator,
  liveSpeaker,
  liveViewer,
}

enum PartyRoleScope { platform, community, conversation, liveSession }

class PartyRole {
  const PartyRole._({
    required this.id,
    required this.partyId,
    required this.type,
    required this.scope,
    required this.validFrom,
    this.scopeId,
    this.validUntil,
  });

  const factory PartyRole.platformUser({
    required String id,
    required String partyId,
    required DateTime validFrom,
    DateTime? validUntil,
  }) = _PlatformUserRole;

  const factory PartyRole.communityOwner({
    required String id,
    required String partyId,
    required String communityId,
    required DateTime validFrom,
    DateTime? validUntil,
  }) = _CommunityOwnerRole;

  const factory PartyRole.communityModerator({
    required String id,
    required String partyId,
    required String communityId,
    required DateTime validFrom,
    DateTime? validUntil,
  }) = _CommunityModeratorRole;

  const factory PartyRole.communityMember({
    required String id,
    required String partyId,
    required String communityId,
    required DateTime validFrom,
    DateTime? validUntil,
  }) = _CommunityMemberRole;

  const factory PartyRole.conversationParticipant({
    required String id,
    required String partyId,
    required String conversationId,
    required DateTime validFrom,
    DateTime? validUntil,
  }) = _ConversationParticipantRole;

  const factory PartyRole.liveHost({
    required String id,
    required String partyId,
    required String liveSessionId,
    required DateTime validFrom,
    DateTime? validUntil,
  }) = _LiveHostRole;

  const factory PartyRole.liveModerator({
    required String id,
    required String partyId,
    required String liveSessionId,
    required DateTime validFrom,
    DateTime? validUntil,
  }) = _LiveModeratorRole;

  const factory PartyRole.liveSpeaker({
    required String id,
    required String partyId,
    required String liveSessionId,
    required DateTime validFrom,
    DateTime? validUntil,
  }) = _LiveSpeakerRole;

  const factory PartyRole.liveViewer({
    required String id,
    required String partyId,
    required String liveSessionId,
    required DateTime validFrom,
    DateTime? validUntil,
  }) = _LiveViewerRole;

  final String id;
  final String partyId;
  final PartyRoleType type;
  final PartyRoleScope scope;
  final String? scopeId;
  final DateTime validFrom;
  final DateTime? validUntil;

  bool isActiveAt(DateTime instant) =>
      !instant.isBefore(validFrom) &&
      (validUntil == null || instant.isBefore(validUntil!));
}

class _PlatformUserRole extends PartyRole {
  const _PlatformUserRole({
    required super.id,
    required super.partyId,
    required super.validFrom,
    super.validUntil,
  }) : super._(
         type: PartyRoleType.platformUser,
         scope: PartyRoleScope.platform,
       );
}

class _CommunityOwnerRole extends PartyRole {
  const _CommunityOwnerRole({
    required super.id,
    required super.partyId,
    required String communityId,
    required super.validFrom,
    super.validUntil,
  }) : super._(
         type: PartyRoleType.communityOwner,
         scope: PartyRoleScope.community,
         scopeId: communityId,
       );
}

class _CommunityModeratorRole extends PartyRole {
  const _CommunityModeratorRole({
    required super.id,
    required super.partyId,
    required String communityId,
    required super.validFrom,
    super.validUntil,
  }) : super._(
         type: PartyRoleType.communityModerator,
         scope: PartyRoleScope.community,
         scopeId: communityId,
       );
}

class _CommunityMemberRole extends PartyRole {
  const _CommunityMemberRole({
    required super.id,
    required super.partyId,
    required String communityId,
    required super.validFrom,
    super.validUntil,
  }) : super._(
         type: PartyRoleType.communityMember,
         scope: PartyRoleScope.community,
         scopeId: communityId,
       );
}

class _ConversationParticipantRole extends PartyRole {
  const _ConversationParticipantRole({
    required super.id,
    required super.partyId,
    required String conversationId,
    required super.validFrom,
    super.validUntil,
  }) : super._(
         type: PartyRoleType.conversationParticipant,
         scope: PartyRoleScope.conversation,
         scopeId: conversationId,
       );
}

class _LiveHostRole extends PartyRole {
  const _LiveHostRole({
    required super.id,
    required super.partyId,
    required String liveSessionId,
    required super.validFrom,
    super.validUntil,
  }) : super._(
         type: PartyRoleType.liveHost,
         scope: PartyRoleScope.liveSession,
         scopeId: liveSessionId,
       );
}

class _LiveModeratorRole extends PartyRole {
  const _LiveModeratorRole({
    required super.id,
    required super.partyId,
    required String liveSessionId,
    required super.validFrom,
    super.validUntil,
  }) : super._(
         type: PartyRoleType.liveModerator,
         scope: PartyRoleScope.liveSession,
         scopeId: liveSessionId,
       );
}

class _LiveSpeakerRole extends PartyRole {
  const _LiveSpeakerRole({
    required super.id,
    required super.partyId,
    required String liveSessionId,
    required super.validFrom,
    super.validUntil,
  }) : super._(
         type: PartyRoleType.liveSpeaker,
         scope: PartyRoleScope.liveSession,
         scopeId: liveSessionId,
       );
}

class _LiveViewerRole extends PartyRole {
  const _LiveViewerRole({
    required super.id,
    required super.partyId,
    required String liveSessionId,
    required super.validFrom,
    super.validUntil,
  }) : super._(
         type: PartyRoleType.liveViewer,
         scope: PartyRoleScope.liveSession,
         scopeId: liveSessionId,
       );
}
