import 'package:flutter_test/flutter_test.dart';
import 'package:indigo/model/live/live_chat_message.dart';
import 'package:indigo/model/live/live_engagement_summary.dart';
import 'package:indigo/model/live/live_moderation_action.dart';
import 'package:indigo/model/live/live_participant.dart';
import 'package:indigo/model/live/live_reaction.dart';
import 'package:indigo/model/live/live_recording.dart';
import 'package:indigo/model/live/live_session.dart';
import 'package:indigo/model/party/party_role.dart';
import 'package:indigo/model/post/post_content.dart';

void main() {
  group('Live models', () {
    final createdAt = DateTime.utc(2026);

    test('links a session to its host, community, and scoped roles', () {
      final hostRole = PartyRole.liveHost(
        id: 'host-role-1',
        partyId: 'party-host',
        liveSessionId: 'live-1',
        validFrom: createdAt,
      );
      final viewerRole = PartyRole.liveViewer(
        id: 'viewer-role-1',
        partyId: 'party-viewer',
        liveSessionId: 'live-1',
        validFrom: createdAt,
      );
      final session = LiveSession(
        id: 'live-1',
        hostPartyRoleId: hostRole.id,
        communityId: 'community-1',
        title: 'Live session',
        status: LiveStatus.live,
        createdAt: createdAt,
        startedAt: createdAt,
      );
      final participant = LiveParticipant(
        id: 'participant-1',
        liveSessionId: session.id,
        partyRoleId: viewerRole.id,
        joinedAt: createdAt,
      );

      expect(hostRole.type, PartyRoleType.liveHost);
      expect(hostRole.scope, PartyRoleScope.liveSession);
      expect(hostRole.scopeId, session.id);
      expect(session.hostPartyRoleId, hostRole.id);
      expect(participant.partyRoleId, viewerRole.id);
      expect(participant.isConnected, isTrue);
    });

    test('connects chat, reactions, and moderation to session roles', () {
      final chatMessage = LiveChatMessage(
        id: 'message-1',
        liveSessionId: 'live-1',
        authorPartyRoleId: 'viewer-role-1',
        content: PostContent(segments: [PostTextSegment(text: 'Hello!')]),
        createdAt: createdAt,
      );
      final reaction = LiveReaction(
        id: 'reaction-1',
        liveSessionId: 'live-1',
        actorPartyRoleId: 'viewer-role-1',
        type: LiveReactionType.heart,
        createdAt: createdAt,
      );
      final action = LiveModerationAction(
        id: 'moderation-1',
        liveSessionId: 'live-1',
        actorPartyRoleId: 'moderator-role-1',
        targetPartyRoleId: 'viewer-role-1',
        targetMessageId: chatMessage.id,
        type: LiveModerationActionType.hideMessage,
        createdAt: createdAt,
      );

      expect(chatMessage.liveSessionId, reaction.liveSessionId);
      expect(reaction.actorPartyRoleId, chatMessage.authorPartyRoleId);
      expect(action.targetMessageId, chatMessage.id);
      expect(action.actorPartyRoleId, isNot(action.targetPartyRoleId));
    });

    test('summarizes live engagement and links a replay to its post', () {
      final summary = LiveEngagementSummary(
        liveSessionId: 'live-1',
        viewerCount: 18,
        peakViewerCount: 27,
        messageCount: 6,
        reactionCounts: {LiveReactionType.heart: 42},
      );
      final recording = LiveRecording(
        id: 'recording-1',
        liveSessionId: summary.liveSessionId,
        status: LiveRecordingStatus.ready,
        mediaUrl: 'https://example.test/live.mp4',
        duration: const Duration(minutes: 15),
        replayPostId: 'post-replay-1',
        createdAt: createdAt,
      );

      expect(summary.viewerCount, 18);
      expect(summary.reactionCounts[LiveReactionType.heart], 42);
      expect(recording.liveSessionId, summary.liveSessionId);
      expect(recording.replayPostId, 'post-replay-1');
    });

    test('keeps reaction summaries immutable', () {
      final counts = {LiveReactionType.heart: 1};
      final summary = LiveEngagementSummary(
        liveSessionId: 'live-1',
        reactionCounts: counts,
      );

      counts[LiveReactionType.heart] = 2;

      expect(summary.reactionCounts[LiveReactionType.heart], 1);
      expect(
        () => summary.reactionCounts[LiveReactionType.heart] = 3,
        throwsUnsupportedError,
      );
    });
  });
}
