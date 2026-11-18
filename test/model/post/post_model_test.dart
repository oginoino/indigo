import 'package:flutter_test/flutter_test.dart';
import 'package:indigo/model/post/post.dart';
import 'package:indigo/model/post/post_comment.dart';
import 'package:indigo/model/post/post_content.dart';
import 'package:indigo/model/post/post_engagement_summary.dart';
import 'package:indigo/model/post/post_interaction.dart';
import 'package:indigo/model/post/post_location.dart';
import 'package:indigo/model/post/post_media.dart';
import 'package:indigo/model/post/post_relationship.dart';
import 'package:indigo/model/post/post_sticker.dart';
import 'package:indigo/model/post/post_tag.dart';
import 'package:indigo/model/post/post_theme.dart';

void main() {
  group('Post models', () {
    test(
      'represents rich text, multiple media, tags and viewer engagement',
      () {
        final post = Post(
          id: 'post-1',
          authorPartyRoleId: 'user-role-1',
          createdAt: DateTime.utc(2026),
          content: PostContent(
            segments: [
              PostTextSegment(text: 'Hello ', styles: {PostTextStyle.bold}),
              PostTextSegment(
                text: '@indigo',
                entity: const PostTextEntity(
                  type: PostTextEntityType.mention,
                  value: 'indigo',
                  id: 'user-2',
                ),
              ),
            ],
          ),
          media: [
            const PostMedia(
              id: 'image-1',
              type: PostMediaType.image,
              sourceUrl: 'https://example.test/image.jpg',
              altText: 'A sample image',
            ),
            const PostMedia(
              id: 'video-1',
              type: PostMediaType.video,
              sourceUrl: 'https://example.test/video.mp4',
              duration: Duration(minutes: 2),
            ),
          ],
          tags: [
            const PostTag(
              id: 'topic-1',
              label: 'design',
              type: PostTagType.topic,
            ),
          ],
          engagement: const PostEngagementSummary(
            reactionCount: 12,
            commentCount: 3,
            viewer: PostViewerEngagement(
              reaction: PostReactionType.like,
              isSaved: true,
            ),
          ),
        );

        expect(post.content.plainText, 'Hello @indigo');
        expect(
          post.content.segments.first.styles,
          contains(PostTextStyle.bold),
        );
        expect(post.media, hasLength(2));
        expect(post.media.last.isVideo, isTrue);
        expect(post.tags.single.label, 'design');
        expect(post.authorPartyRoleId, 'user-role-1');
        expect(post.engagement.viewer.isReacted, isTrue);
        expect(post.engagement.viewer.isSaved, isTrue);
        expect(post.isEphemeral, isFalse);
      },
    );

    test('relates title, theme, location, and stickers to the post', () {
      const theme = PostTheme(
        id: 'theme-1',
        name: 'Sunset',
        backgroundColorHex: '#FF8800',
        foregroundColorHex: '#FFFFFF',
      );
      final location = PostLocation(
        placeId: 'place-1',
        name: 'San Francisco',
        locality: 'San Francisco',
        countryCode: 'US',
        precision: PostLocationPrecision.city,
        coordinates: GeoCoordinates(latitude: 37.7749, longitude: -122.4194),
      );
      const image = PostMedia(
        id: 'image-1',
        type: PostMediaType.image,
        sourceUrl: 'https://example.test/image.jpg',
      );
      final post = Post(
        id: 'post-1',
        authorPartyRoleId: 'user-role-1',
        content: PostContent(segments: [PostTextSegment(text: 'Hello')]),
        title: 'A day in the city',
        themeId: theme.id,
        location: location,
        media: const [image],
        stickers: [
          PostSticker(
            id: 'sticker-1',
            payload: const AssetStickerPayload(assetId: 'asset-1'),
            position: PostStickerPosition(x: 0.5, y: 0.5),
            targetMediaId: 'image-1',
          ),
          PostSticker(
            id: 'sticker-2',
            payload: TextStickerPayload(
              content: PostContent(
                segments: [PostTextSegment(text: 'Good day')],
              ),
            ),
            position: PostStickerPosition(x: 0.25, y: 0.75),
          ),
        ],
        createdAt: DateTime.utc(2026),
      );

      expect(post.hasTitle, isTrue);
      expect(post.themeId, theme.id);
      expect(post.hasLocation, isTrue);
      expect(post.location?.hasCoordinates, isTrue);
      expect(post.hasStickers, isTrue);
      expect(post.stickers.first.isAttachedToMedia, isTrue);
      expect(post.stickers.last.isAttachedToMedia, isFalse);
    });

    test('rejects stickers referencing media outside the post', () {
      expect(
        () => Post(
          id: 'post-1',
          authorPartyRoleId: 'user-role-1',
          content: PostContent(segments: [PostTextSegment(text: 'Hello')]),
          stickers: [
            PostSticker(
              id: 'sticker-1',
              payload: const AssetStickerPayload(assetId: 'asset-1'),
              position: PostStickerPosition(x: 0.5, y: 0.5),
              targetMediaId: 'missing-image',
            ),
          ],
          createdAt: DateTime.utc(2026),
        ),
        throwsArgumentError,
      );
    });

    test('validates coordinates and normalized sticker placement', () {
      expect(
        () => GeoCoordinates(latitude: 91, longitude: 0),
        throwsArgumentError,
      );
      expect(() => PostStickerPosition(x: 1.1, y: 0.5), throwsArgumentError);
    });

    test('represents ephemeral posts and quote/repost relationships', () {
      final post = Post(
        id: 'post-2',
        authorPartyRoleId: 'user-role-1',
        createdAt: DateTime.utc(2026),
        content: PostContent(segments: [PostTextSegment(text: 'A response')]),
        relationship: const PostRelationship(
          type: PostRelationshipType.quote,
          targetPostId: 'original-post',
        ),
        expiresAt: DateTime.utc(2026, 1, 2),
      );

      expect(post.isEphemeral, isTrue);
      expect(post.relationship?.type, PostRelationshipType.quote);
      expect(post.relationship?.targetPostId, 'original-post');
    });

    test('represents threaded comments independently of the post', () {
      final comment = PostComment(
        id: 'comment-1',
        postId: 'post-1',
        parentCommentId: 'comment-parent',
        authorPartyRoleId: 'user-role-1',
        content: PostContent(segments: [PostTextSegment(text: 'Reply')]),
        createdAt: DateTime.utc(2026),
      );

      expect(comment.isReply, isTrue);
      expect(comment.parentCommentId, 'comment-parent');
      expect(comment.authorPartyRoleId, 'user-role-1');
    });

    test('models reactions, saves, and shares as separate actor records', () {
      final reaction = PostReaction(
        id: 'reaction-1',
        postId: 'post-1',
        actorPartyRoleId: 'user-role-1',
        type: PostReactionType.love,
        createdAt: DateTime.utc(2026),
      );
      final commentReaction = CommentReaction(
        id: 'comment-reaction-1',
        commentId: 'comment-1',
        actorPartyRoleId: 'user-role-1',
        type: PostReactionType.like,
        createdAt: DateTime.utc(2026),
      );
      final save = PostSave(
        id: 'save-1',
        postId: 'post-1',
        actorPartyRoleId: 'user-role-1',
        createdAt: DateTime.utc(2026),
      );
      final quotedPost = Post(
        id: 'quoted-post-1',
        authorPartyRoleId: 'user-role-1',
        content: PostContent(segments: [PostTextSegment(text: 'My response')]),
        createdAt: DateTime.utc(2026),
        relationship: const PostRelationship(
          type: PostRelationshipType.quote,
          targetPostId: 'post-1',
        ),
      );
      final feedShare = PostShare.toFeed(
        id: 'feed-share-1',
        postId: 'post-1',
        actorPartyRoleId: 'user-role-1',
        responsePostId: quotedPost.id,
        createdAt: DateTime.utc(2026),
      );
      final share = PostShare.toConversation(
        id: 'share-1',
        postId: 'post-1',
        actorPartyRoleId: 'user-role-1',
        conversationId: 'conversation-1',
        responseMessageId: 'message-1',
        createdAt: DateTime.utc(2026),
      );

      expect(reaction.isActive, isTrue);
      expect(commentReaction.commentId, 'comment-1');
      expect(save.postId, 'post-1');
      expect(feedShare.responsePostId, quotedPost.id);
      expect(quotedPost.relationship?.targetPostId, feedShare.postId);
      expect(share.destination, PostShareDestination.conversation);
      expect(share.conversationId, 'conversation-1');
      expect(share.responseMessageId, 'message-1');
    });

    test('exposes unmodifiable collections', () {
      final segments = [PostTextSegment(text: 'Text')];
      final content = PostContent(segments: segments);

      segments.add(PostTextSegment(text: ' added later'));

      expect(content.segments, hasLength(1));
      expect(
        () => content.segments.add(PostTextSegment(text: 'forbidden')),
        throwsUnsupportedError,
      );
    });
  });
}
