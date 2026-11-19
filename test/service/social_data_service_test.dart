import 'package:flutter_test/flutter_test.dart';
import 'package:indigo/service/social_data_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AssetSocialDataService', () {
    test('loads mock data and supports common UI queries', () async {
      final service = AssetSocialDataService();

      await service.load();

      final data = service.data;
      expect(data.schemaVersion, 4);
      expect(data.profileForParty(data.currentUserPartyId), isNotNull);
      expect(data.postById('post-river-walk'), isNotNull);
      expect(data.commentsForPost('post-river-walk'), hasLength(2));
      final longPost = data.postById('post-morning-walk-notes')!;
      final longPostContent = longPost['content'] as JsonObject;
      final longPostText = (longPostContent['segments'] as List)
          .map((segment) => (segment as JsonObject)['text'] as String)
          .join();
      expect(longPostText.length, greaterThan(500));
      expect(data.commentsForPost('post-morning-walk-notes'), hasLength(2));
      expect(
        (data.postById('post-city-details')!['media'] as List),
        hasLength(4),
      );
      expect(data.postById('post-pan-cheese'), isNotNull);
      expect(
        data.messagesForConversation('conversation-ana-lucas'),
        hasLength(3),
      );
      expect(data.chatMessagesForLive('live-photo-walk'), hasLength(4));
      expect(data.liveSessionById('live-photo-walk'), isNotNull);

      final mediaTypes = data.posts
          .expand((post) => post['media'] as List<dynamic>)
          .map((media) => (media as JsonObject)['type'])
          .toSet();
      expect(mediaTypes, containsAll(['image', 'gif', 'video']));
      final videoSourceUrls = data.posts
          .expand((post) => post['media'] as List<dynamic>)
          .where((media) => (media as JsonObject)['type'] == 'video')
          .map((media) => (media as JsonObject)['source_url'] as String)
          .toList();
      expect(videoSourceUrls, hasLength(4));
      expect(
        videoSourceUrls,
        isNot(
          contains(
            'https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
          ),
        ),
      );
    });

    test('fixture references resolve across its domain sections', () async {
      final service = AssetSocialDataService();
      await service.load();
      final data = service.data;

      final partyIds = _ids(data.parties);
      final roleIds = _ids(data.partyRoles);
      final communityIds = _ids(data.communities);
      final conversationIds = _ids(data.conversations);
      final postIds = _ids(data.posts);
      final commentIds = _ids(data.comments);
      final liveSessionIds = _ids(data.liveSessions);
      final liveMessageIds = _ids(data.liveChatMessages);
      final themeIds = _ids(data.postThemes);
      final hashtagIds = _ids(data.hashtags);
      final hashtagsById = {
        for (final hashtag in data.hashtags) hashtag['id'] as String: hashtag,
      };
      final stickerAssetIds = _ids(data.stickerAssets);

      expect(partyIds, contains(data.currentUserPartyId));
      for (final friendship in data.friendships) {
        expect(partyIds, contains(friendship['requester_party_id']));
        expect(partyIds, contains(friendship['recipient_party_id']));
      }
      for (final community in data.communities) {
        expect(roleIds, contains(community['created_by_party_role_id']));
      }
      for (final hashtag in data.hashtags) {
        final communityId = hashtag['community_id'];
        if (communityId != null) {
          expect(communityIds, contains(communityId));
        }
      }
      for (final conversation in data.conversations) {
        expect(roleIds, contains(conversation['created_by_party_role_id']));
      }
      for (final profile in data.userProfiles) {
        expect(partyIds, contains(profile['party_id']));
        expect(roleIds, contains(profile['platform_user_role_id']));
      }
      for (final role in data.partyRoles) {
        expect(partyIds, contains(role['party_id']));
        final scopeId = role['scope_id'];
        if (scopeId == null) continue;

        final scopedIds = switch (role['scope']) {
          'community' => communityIds,
          'conversation' => conversationIds,
          'liveSession' => liveSessionIds,
          _ => <String>{},
        };
        expect(scopedIds, contains(scopeId));
      }
      for (final post in data.posts) {
        expect(roleIds, contains(post['author_party_role_id']));
        for (final tag in post['tags'] as List<dynamic>) {
          final tagData = tag as JsonObject;
          if (tagData['type'] != 'user') {
            expect(hashtagIds, contains(tagData['id']));
            expect(hashtagsById[tagData['id']]?['label'], tagData['label']);
          }
        }
        final content = post['content'] as JsonObject;
        for (final segment in content['segments'] as List<dynamic>) {
          final entity = (segment as JsonObject)['entity'];
          if (entity is JsonObject && entity['type'] == 'hashtag') {
            expect(hashtagIds, contains(entity['id']));
            expect(hashtagsById[entity['id']]?['label'], entity['value']);
          }
        }
        final themeId = post['theme_id'];
        if (themeId != null) expect(themeIds, contains(themeId));
        final mediaIds = {
          for (final media in post['media'] as List<dynamic>)
            (media as JsonObject)['id'] as String,
        };
        for (final sticker in post['stickers'] as List<dynamic>) {
          final stickerData = sticker as JsonObject;
          final targetMediaId = stickerData['target_media_id'];
          if (targetMediaId != null) {
            expect(mediaIds, contains(targetMediaId));
          }
          final payload = stickerData['payload'] as JsonObject;
          if (payload['type'] == 'asset') {
            expect(stickerAssetIds, contains(payload['asset_id']));
          }
        }
        final relationship = post['relationship'];
        if (relationship != null) {
          expect(
            postIds,
            contains((relationship as JsonObject)['target_post_id']),
          );
        }
      }
      for (final comment in data.comments) {
        expect(postIds, contains(comment['post_id']));
        expect(roleIds, contains(comment['author_party_role_id']));
        final parentId = comment['parent_comment_id'];
        if (parentId != null) expect(commentIds, contains(parentId));
      }
      for (final reaction in data.postReactions) {
        expect(postIds, contains(reaction['post_id']));
        expect(roleIds, contains(reaction['actor_party_role_id']));
      }
      for (final reaction in data.commentReactions) {
        expect(commentIds, contains(reaction['comment_id']));
        expect(roleIds, contains(reaction['actor_party_role_id']));
      }
      for (final save in data.postSaves) {
        expect(postIds, contains(save['post_id']));
        expect(roleIds, contains(save['actor_party_role_id']));
      }
      for (final share in data.postShares) {
        expect(postIds, contains(share['post_id']));
        expect(roleIds, contains(share['actor_party_role_id']));
        final responsePostId = share['response_post_id'];
        if (responsePostId != null) {
          expect(postIds, contains(responsePostId));
          final responsePost = data.postById(responsePostId)!;
          final relationship = responsePost['relationship'] as JsonObject;
          expect(relationship['target_post_id'], share['post_id']);
        }
        final conversationId = share['conversation_id'];
        if (conversationId != null) {
          expect(conversationIds, contains(conversationId));
        }
        final responseMessageId = share['response_message_id'];
        if (responseMessageId != null) {
          final responseMessage = data.conversationMessages.singleWhere(
            (message) => message['id'] == responseMessageId,
          );
          expect(responseMessage['shared_post_id'], share['post_id']);
        }
      }
      for (final message in data.conversationMessages) {
        expect(conversationIds, contains(message['conversation_id']));
        expect(roleIds, contains(message['sender_party_role_id']));
        final sharedPostId = message['shared_post_id'];
        if (sharedPostId != null) expect(postIds, contains(sharedPostId));
      }
      for (final live in data.liveSessions) {
        expect(roleIds, contains(live['host_party_role_id']));
        final communityId = live['community_id'];
        if (communityId != null) expect(communityIds, contains(communityId));
      }
      for (final participant in data.liveParticipants) {
        expect(liveSessionIds, contains(participant['live_session_id']));
        expect(roleIds, contains(participant['party_role_id']));
      }
      for (final message in data.liveChatMessages) {
        expect(liveSessionIds, contains(message['live_session_id']));
        expect(roleIds, contains(message['author_party_role_id']));
      }
      for (final reaction in data.liveReactions) {
        expect(liveSessionIds, contains(reaction['live_session_id']));
        expect(roleIds, contains(reaction['actor_party_role_id']));
        final targetRoleId = reaction['target_party_role_id'];
        if (targetRoleId != null) expect(roleIds, contains(targetRoleId));
      }
      for (final summary in data.liveEngagementSummaries) {
        expect(liveSessionIds, contains(summary['live_session_id']));
      }
      for (final action in data.liveModerationActions) {
        expect(liveSessionIds, contains(action['live_session_id']));
        expect(roleIds, contains(action['actor_party_role_id']));
        final targetRoleId = action['target_party_role_id'];
        if (targetRoleId != null) expect(roleIds, contains(targetRoleId));
        final targetMessageId = action['target_message_id'];
        if (targetMessageId != null) {
          expect(liveMessageIds, contains(targetMessageId));
        }
      }
      for (final recording in data.liveRecordings) {
        expect(liveSessionIds, contains(recording['live_session_id']));
        final replayPostId = recording['replay_post_id'];
        if (replayPostId != null) expect(postIds, contains(replayPostId));
      }
    });
  });
}

Set<String> _ids(List<JsonObject> records) =>
    records.map((record) => record['id'] as String).toSet();
