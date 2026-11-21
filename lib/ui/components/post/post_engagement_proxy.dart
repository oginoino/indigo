import '../../../model/post/post.dart';
import '../../../model/post/post_content.dart';
import '../../../model/post/post_engagement_summary.dart';
import '../../../model/post/post_location.dart';
import '../../../model/post/post_media.dart';
import '../../../model/post/post_relationship.dart';
import '../../../model/post/post_sticker.dart';
import '../../../model/post/post_tag.dart';

/// Proxy leve de [Post] que substitui apenas [engagement] por um override
/// otimista sem copiar todo o objeto.
///
/// Usado em contextos de tela cheia (viewer de fotos, player de vídeo) e no
/// feed card para propagar o engajamento otimista ao [PostEngagementBar].
class PostEngagementProxy implements Post {
  const PostEngagementProxy(this._base, this._engagement);

  final Post _base;
  final PostEngagementSummary _engagement;

  @override
  PostEngagementSummary get engagement => _engagement;

  // ---- Delegação de todos os outros membros ----------------------------------
  @override
  String get id => _base.id;
  @override
  String get authorPartyRoleId => _base.authorPartyRoleId;
  @override
  PostContent get content => _base.content;
  @override
  String? get title => _base.title;
  @override
  String? get themeId => _base.themeId;
  @override
  PostLocation? get location => _base.location;
  @override
  List<PostMedia> get media => _base.media;
  @override
  List<PostSticker> get stickers => _base.stickers;
  @override
  List<PostTag> get tags => _base.tags;
  @override
  List<String> get feeds => _base.feeds;
  @override
  PostRelationship? get relationship => _base.relationship;
  @override
  PostVisibility get visibility => _base.visibility;
  @override
  PostStatus get status => _base.status;
  @override
  DateTime get createdAt => _base.createdAt;
  @override
  DateTime? get updatedAt => _base.updatedAt;
  @override
  DateTime? get expiresAt => _base.expiresAt;
  @override
  bool get isEphemeral => _base.isEphemeral;
  @override
  bool get hasTitle => _base.hasTitle;
  @override
  bool get hasLocation => _base.hasLocation;
  @override
  bool get hasStickers => _base.hasStickers;
  @override
  bool get hasVideo => _base.hasVideo;
  @override
  bool isPublishedAt(DateTime instant) => _base.isPublishedAt(instant);
}
