enum PostRelationshipType { reply, quote }

class PostRelationship {
  const PostRelationship({required this.type, required this.targetPostId});

  final PostRelationshipType type;
  final String targetPostId;
}
