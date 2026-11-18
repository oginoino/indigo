enum PostTextStyle { bold, italic, underline, strikethrough, code }

enum PostTextEntityType { mention, hashtag, link }

class PostTextEntity {
  const PostTextEntity({required this.type, required this.value, this.id});

  final PostTextEntityType type;
  final String value;
  final String? id;
}

class PostTextSegment {
  PostTextSegment({
    required this.text,
    Set<PostTextStyle> styles = const {},
    this.entity,
  }) : styles = Set.unmodifiable(styles);

  final String text;
  final Set<PostTextStyle> styles;
  final PostTextEntity? entity;
}

class PostContent {
  PostContent({required List<PostTextSegment> segments})
    : segments = List.unmodifiable(segments);

  final List<PostTextSegment> segments;

  String get plainText => segments.map((segment) => segment.text).join();
}
