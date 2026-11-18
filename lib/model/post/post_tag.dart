enum PostTagType { hashtag, topic, user }

class PostTag {
  const PostTag({required this.id, required this.label, required this.type});

  final String id;
  final String label;
  final PostTagType type;
}
