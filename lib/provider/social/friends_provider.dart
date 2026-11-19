import 'package:flutter/foundation.dart';

import '../../model/party/user_profile.dart';
import '../../model/social/friendship.dart';
import '../../service/mapper/friendship_json_mapper.dart';
import '../../service/mapper/user_profile_json_mapper.dart';
import '../../service/social_data_service.dart';

class FriendsProvider extends ChangeNotifier {
  FriendsProvider({required SocialDataService socialDataService})
    : _currentUser = _resolveCurrentUser(socialDataService),
      _friends = _resolveFriends(socialDataService);

  final UserProfile? _currentUser;
  final List<UserProfile> _friends;

  UserProfile? get currentUser => _currentUser;
  List<UserProfile> get friends => _friends;
  bool get hasFriends => _friends.isNotEmpty;

  static UserProfile? _resolveCurrentUser(SocialDataService socialDataService) {
    final data = socialDataService.data;
    final profileJson = data.profileForParty(data.currentUserPartyId);
    return profileJson == null ? null : UserProfileJsonMapper.fromJson(profileJson);
  }

  static List<UserProfile> _resolveFriends(
    SocialDataService socialDataService,
  ) {
    final data = socialDataService.data;
    final currentUserPartyId = data.currentUserPartyId;
    final seenPartyIds = <String>{};
    final friends = <UserProfile>[];

    for (final json in data.friendships) {
      final friendship = FriendshipJsonMapper.fromJson(json);
      if (friendship.status != FriendshipStatus.accepted) continue;

      final friendPartyId = switch (currentUserPartyId) {
        final id when friendship.requesterPartyId == id =>
          friendship.recipientPartyId,
        final id when friendship.recipientPartyId == id =>
          friendship.requesterPartyId,
        _ => null,
      };
      if (friendPartyId == null || !seenPartyIds.add(friendPartyId)) continue;

      final profileJson = data.profileForParty(friendPartyId);
      if (profileJson == null) continue;

      friends.add(UserProfileJsonMapper.fromJson(profileJson));
    }

    return List.unmodifiable(friends);
  }
}
