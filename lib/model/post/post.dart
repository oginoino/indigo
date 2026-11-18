import 'post_content.dart';
import 'post_engagement_summary.dart';
import 'post_media.dart';
import 'post_relationship.dart';
import 'post_location.dart';
import 'post_sticker.dart';
import 'post_tag.dart';

enum PostVisibility { public, followers, mentionedUsers, private }

enum PostStatus { draft, published, archived, deleted }

class Post {
  Post({
    required this.id,
    required this.authorPartyRoleId,
    required this.content,
    required this.createdAt,
    this.title,
    this.themeId,
    this.location,
    List<PostMedia> media = const [],
    List<PostSticker> stickers = const [],
    List<PostTag> tags = const [],
    this.engagement = const PostEngagementSummary(),
    this.relationship,
    this.visibility = PostVisibility.public,
    this.status = PostStatus.published,
    this.updatedAt,
    this.expiresAt,
  }) : media = List.unmodifiable(media),
       stickers = List.unmodifiable(stickers),
       tags = List.unmodifiable(tags) {
    final mediaIds = this.media.map((item) => item.id).toSet();
    for (final sticker in this.stickers) {
      final targetMediaId = sticker.targetMediaId;
      if (targetMediaId != null && !mediaIds.contains(targetMediaId)) {
        throw ArgumentError.value(targetMediaId, 'stickers');
      }
    }
  }

  final String id;
  final String authorPartyRoleId;
  final PostContent content;
  final String? title;
  final String? themeId;
  final PostLocation? location;
  final List<PostMedia> media;
  final List<PostSticker> stickers;
  final List<PostTag> tags;
  final PostEngagementSummary engagement;
  final PostRelationship? relationship;
  final PostVisibility visibility;
  final PostStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? expiresAt;

  bool get isEphemeral => expiresAt != null;
  bool get hasTitle => title?.isNotEmpty ?? false;
  bool get hasLocation => location != null;
  bool get hasStickers => stickers.isNotEmpty;
  bool get hasVideo => media.any((item) => item.isVideo);

  bool isPublishedAt(DateTime instant) =>
      status == PostStatus.published &&
      (expiresAt == null || expiresAt!.isAfter(instant));
}
