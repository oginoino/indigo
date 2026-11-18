import '../../model/party/user_profile.dart';
import '../../util/const/app/app_strings.dart';
import '../../util/const/app/social_data_constants.dart';
import '../social_data_service.dart';

class UserProfileJsonMapper {
  const UserProfileJsonMapper._();

  static UserProfile fromJson(JsonObject json) => UserProfile(
    partyId: _requiredString(json, SocialDataConstants.partyIdKey),
    platformUserRoleId: _requiredString(
      json,
      SocialDataConstants.platformUserRoleIdKey,
    ),
    username: _requiredString(json, SocialDataConstants.usernameKey),
    displayName: _requiredString(json, SocialDataConstants.displayNameKey),
    avatarUrl: _optionalString(json, SocialDataConstants.avatarUrlKey),
    bio: _optionalString(json, SocialDataConstants.bioKey),
    createdAt: _dateTime(json, SocialDataConstants.createdAtKey),
  );

  static String _requiredString(JsonObject json, String key) {
    final value = json[key];
    if (value is! String) throw _invalidField(key);
    return value;
  }

  static String? _optionalString(JsonObject json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is! String) throw _invalidField(key);
    return value;
  }

  static DateTime _dateTime(JsonObject json, String key) {
    final value = _requiredString(json, key);
    return DateTime.tryParse(value) ?? (throw _invalidField(key));
  }

  static FormatException _invalidField(String field) => FormatException(
    AppStrings.invalidSocialUserProfileField.replaceAll('{field}', field),
  );
}
