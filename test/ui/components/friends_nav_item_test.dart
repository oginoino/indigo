import 'package:flutter_test/flutter_test.dart';
import 'package:indigo/model/feed_item.dart';
import 'package:indigo/provider/social/friends_provider.dart';
import 'package:indigo/service/social_data_service.dart';
import 'package:indigo/ui/components/app_bar/friends_nav_item.dart';
import 'package:indigo/ui/components/avatar.dart';
import 'package:indigo/ui/components/avatar_group.dart';
import 'package:indigo/util/const/app/app_strings.dart';
import 'package:indigo/util/const/app/social_data_constants.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const friendsFeed = FeedItem(
    id: 2,
    name: 'Amigos',
    icon: 'friends',
    route: '/friends',
  );

  testWidgets('shows friend avatars and the feed name when friends exist', (
    tester,
  ) async {
    final provider = FriendsProvider(
      socialDataService: _FakeSocialDataService(
        _socialData(
          profiles: [_profile('party-lucas', 'Lucas Mendes')],
          friendships: [
            _friendship(
              requester: 'party-ana',
              recipient: 'party-lucas',
              status: 'accepted',
            ),
          ],
        ),
      ),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: Scaffold(body: FriendsNavItem(feedItem: friendsFeed)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AvatarGroup), findsOneWidget);
    expect(find.text('Amigos'), findsOneWidget);
    expect(find.text(AppStrings.addFriends), findsNothing);
    provider.dispose();
  });

  testWidgets('shows up to three friend avatars and an overflow counter', (
    tester,
  ) async {
    final provider = FriendsProvider(
      socialDataService: _FakeSocialDataService(
        _socialData(
          profiles: [
            _profile('party-lucas', 'Lucas Mendes'),
            _profile('party-maya', 'Maya Ribeiro'),
            _profile('party-rafa', 'Rafa Nunes'),
            _profile('party-bia', 'Bia Lima'),
          ],
          friendships: [
            for (final recipient in const [
              'party-lucas',
              'party-maya',
              'party-rafa',
              'party-bia',
            ])
              _friendship(
                requester: 'party-ana',
                recipient: recipient,
                status: 'accepted',
              ),
          ],
        ),
      ),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: Scaffold(body: FriendsNavItem(feedItem: friendsFeed)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Avatar), findsNWidgets(3));
    expect(find.text('+1'), findsOneWidget);
    provider.dispose();
  });

  testWidgets('shows the add friends CTA when there are no friends', (
    tester,
  ) async {
    final provider = FriendsProvider(
      socialDataService: _FakeSocialDataService(_socialData()),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: Scaffold(body: FriendsNavItem(feedItem: friendsFeed)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.addFriends), findsOneWidget);
    expect(find.text('Amigos'), findsNothing);
    provider.dispose();
  });
}

SocialMockData _socialData({
  List<Map<String, dynamic>> profiles = const [],
  List<Map<String, dynamic>> friendships = const [],
}) {
  return SocialMockData.fromJson({
    SocialDataConstants.schemaVersionKey: 3,
    SocialDataConstants.currentUserPartyIdKey: 'party-ana',
    for (final section in SocialDataConstants.sections) section: <dynamic>[],
    SocialDataConstants.userProfilesKey: profiles,
    SocialDataConstants.friendshipsKey: friendships,
  });
}

Map<String, dynamic> _profile(String partyId, String displayName) => {
  SocialDataConstants.partyIdKey: partyId,
  SocialDataConstants.platformUserRoleIdKey: 'role-$partyId',
  SocialDataConstants.usernameKey: partyId,
  SocialDataConstants.displayNameKey: displayName,
  SocialDataConstants.createdAtKey: '2024-02-11T10:00:00Z',
};

Map<String, dynamic> _friendship({
  required String requester,
  required String recipient,
  required String status,
}) => {
  SocialDataConstants.idKey: 'friendship-$requester-$recipient',
  SocialDataConstants.requesterPartyIdKey: requester,
  SocialDataConstants.recipientPartyIdKey: recipient,
  SocialDataConstants.statusKey: status,
  SocialDataConstants.requestedAtKey: '2025-04-10T10:00:00Z',
};

class _FakeSocialDataService implements SocialDataService {
  _FakeSocialDataService(this._data);

  final SocialMockData _data;

  @override
  Future<void> load() async {}

  @override
  SocialMockData get data => _data;
}
