import '../../model/hashtag.dart';
import '../social_data_service.dart';

class HashtagJsonMapper {
  const HashtagJsonMapper._();

  static Hashtag fromJson(JsonObject json) {
    final id = json['id'];
    final label = json['label'];
    final rawType = json['type'];
    final emoji = json['emoji'];
    final communityId = json['community_id'];
    final type = HashtagType.values.where((value) => value.name == rawType);

    if (id is! String ||
        label is! String ||
        type.isEmpty ||
        (emoji != null && emoji is! String) ||
        (communityId != null && communityId is! String) ||
        (rawType == HashtagType.community.name && communityId is! String)) {
      throw const FormatException('Invalid hashtag data.');
    }

    return Hashtag(
      id: id,
      label: label,
      type: type.first,
      emoji: emoji as String?,
      communityId: communityId as String?,
    );
  }
}
