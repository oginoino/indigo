import '../../model/social/friendship.dart';
import '../../util/const/app/app_strings.dart';
import '../../util/const/app/social_data_constants.dart';
import '../social_data_service.dart';

class FriendshipJsonMapper {
  const FriendshipJsonMapper._();

  static Friendship fromJson(JsonObject json) => Friendship(
    id: _requiredString(json, SocialDataConstants.idKey),
    requesterPartyId: _requiredString(
      json,
      SocialDataConstants.requesterPartyIdKey,
    ),
    recipientPartyId: _requiredString(
      json,
      SocialDataConstants.recipientPartyIdKey,
    ),
    status: _status(json, SocialDataConstants.statusKey),
    requestedAt: _dateTime(json, SocialDataConstants.requestedAtKey),
    respondedAt: _optionalDateTime(json, SocialDataConstants.respondedAtKey),
  );

  static FriendshipStatus _status(JsonObject json, String key) {
    final value = _requiredString(json, key);
    return FriendshipStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => throw _invalidField(key),
    );
  }

  static String _requiredString(JsonObject json, String key) {
    final value = json[key];
    if (value is! String) throw _invalidField(key);
    return value;
  }

  static DateTime _dateTime(JsonObject json, String key) {
    final value = _requiredString(json, key);
    return DateTime.tryParse(value) ?? (throw _invalidField(key));
  }

  static DateTime? _optionalDateTime(JsonObject json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is! String) throw _invalidField(key);
    return DateTime.tryParse(value) ?? (throw _invalidField(key));
  }

  static FormatException _invalidField(String field) => FormatException(
    AppStrings.invalidSocialFriendshipField.replaceAll('{field}', field),
  );
}
