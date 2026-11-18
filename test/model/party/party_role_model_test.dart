import 'package:flutter_test/flutter_test.dart';
import 'package:indigo/model/party/party.dart';
import 'package:indigo/model/party/party_role.dart';
import 'package:indigo/model/party/user_profile.dart';
import 'package:indigo/model/post/post_content.dart';
import 'package:indigo/model/post/post_interaction.dart';
import 'package:indigo/model/social/community.dart';
import 'package:indigo/model/social/conversation.dart';
import 'package:indigo/model/social/conversation_message.dart';
import 'package:indigo/model/social/friendship.dart';

void main() {
  group('PartyRole models', () {
    final start = DateTime.utc(2026);
    final end = DateTime.utc(2027);

    test('associates a user profile with a person and platform role', () {
      final party = Party(
        id: 'party-1',
        type: PartyType.person,
        createdAt: DateTime.utc(2026),
      );
      final role = PartyRole.platformUser(
        id: 'role-1',
        partyId: 'party-1',
        validFrom: DateTime.utc(2026),
      );
      final profile = UserProfile(
        partyId: 'party-1',
        platformUserRoleId: 'role-1',
        username: 'indigo_user',
        displayName: 'Indigo User',
        createdAt: DateTime.utc(2026),
      );

      expect(party.type, PartyType.person);
      expect(role.type, PartyRoleType.platformUser);
      expect(role.scope, PartyRoleScope.platform);
      expect(profile.partyId, party.id);
      expect(profile.platformUserRoleId, role.id);
    });

    test('scopes community and conversation roles to their context', () {
      final communityRole = PartyRole.communityMember(
        id: 'membership-1',
        partyId: 'party-1',
        communityId: 'community-1',
        validFrom: DateTime.utc(2026),
      );
      final conversationRole = PartyRole.conversationParticipant(
        id: 'participant-1',
        partyId: 'party-1',
        conversationId: 'conversation-1',
        validFrom: DateTime.utc(2026),
      );

      expect(communityRole.scope, PartyRoleScope.community);
      expect(communityRole.scopeId, 'community-1');
      expect(conversationRole.scope, PartyRoleScope.conversation);
      expect(conversationRole.scopeId, 'conversation-1');
    });

    test('evaluates role validity as a half-open date interval', () {
      final role = PartyRole.platformUser(
        id: 'role-1',
        partyId: 'party-1',
        validFrom: start,
        validUntil: end,
      );

      expect(role.isActiveAt(start), isTrue);
      expect(role.isActiveAt(end), isFalse);
      expect(
        role.isActiveAt(start.subtract(const Duration(seconds: 1))),
        isFalse,
      );
    });

    test('references party roles from social actions and conversations', () {
      final community = Community(
        id: 'community-1',
        name: 'Design',
        createdByPartyRoleId: 'role-1',
        createdAt: start,
      );
      final friendship = Friendship(
        id: 'friendship-1',
        requesterPartyId: 'party-1',
        recipientPartyId: 'party-2',
        status: FriendshipStatus.pending,
        requestedAt: start,
      );
      final conversation = Conversation(
        id: 'conversation-1',
        type: ConversationType.direct,
        createdByPartyRoleId: 'role-1',
        createdAt: start,
      );
      final message = ConversationMessage(
        id: 'message-1',
        conversationId: conversation.id,
        senderPartyRoleId: 'role-1',
        content: PostContent(segments: [PostTextSegment(text: 'Hello')]),
        sharedPostId: 'post-1',
        createdAt: start,
      );
      final interaction = PostReaction(
        id: 'interaction-1',
        postId: 'post-1',
        actorPartyRoleId: 'role-1',
        type: PostReactionType.like,
        createdAt: start,
      );

      expect(community.createdByPartyRoleId, 'role-1');
      expect(friendship.status, FriendshipStatus.pending);
      expect(message.senderPartyRoleId, 'role-1');
      expect(message.sharedPostId, 'post-1');
      expect(interaction.actorPartyRoleId, 'role-1');
    });
  });
}
