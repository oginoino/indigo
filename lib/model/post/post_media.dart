enum PostMediaType { image, gif, video }

class PostMedia {
  const PostMedia({
    required this.id,
    required this.type,
    required this.sourceUrl,
    this.thumbnailUrl,
    this.altText,
    this.mimeType,
    this.width,
    this.height,
    this.duration,
  });

  final String id;
  final PostMediaType type;
  final String sourceUrl;
  final String? thumbnailUrl;
  final String? altText;
  final String? mimeType;
  final int? width;
  final int? height;
  final Duration? duration;

  bool get isVideo => type == PostMediaType.video;
}
