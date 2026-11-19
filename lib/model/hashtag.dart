enum HashtagType { user, official, community }

class Hashtag {
  const Hashtag({
    required this.id,
    required this.label,
    required this.type,
    this.emoji,
    this.communityId,
  });

  final String id;
  final String label;
  final HashtagType type;
  final String? emoji;
  final String? communityId;

  String get displayLabel => '${emoji == null ? '' : '$emoji '}#$label';

  String get route => '/hashtags/${Uri.encodeComponent(id)}';
}
