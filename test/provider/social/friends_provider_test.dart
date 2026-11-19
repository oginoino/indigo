import 'package:flutter_test/flutter_test.dart';
import 'package:indigo/provider/social/friends_provider.dart';
import 'package:indigo/service/social_data_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FriendsProvider', () {
    test('resolves accepted friends and ignores pending requests', () async {
      final socialDataService = AssetSocialDataService();
      await socialDataService.load();

      final provider = FriendsProvider(socialDataService: socialDataService);

      expect(provider.hasFriends, isTrue);
      expect(provider.friends.map((friend) => friend.partyId), [
        'party-lucas',
        'party-maya',
      ]);
      expect(
        provider.friends.map((friend) => friend.displayName),
        ['Lucas Mendes', 'Maya Ribeiro'],
      );
      provider.dispose();
    });
  });
}
