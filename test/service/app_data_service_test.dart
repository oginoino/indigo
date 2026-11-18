import 'package:flutter_test/flutter_test.dart';
import 'package:indigo/service/app_data_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AssetAppDataService', () {
    test('loads both navigation collections from app data', () async {
      final service = AssetAppDataService();

      await service.load();

      expect(service.feeds, isNotEmpty);
      expect(service.bottomNavigationItems, isNotEmpty);
      expect(service.feeds.every((feed) => feed.route.startsWith('/')), isTrue);
    });

    test('allows repeated loads without changing configuration', () async {
      final service = AssetAppDataService();

      await service.load();
      final initialFeeds = service.feeds;
      await service.load();

      expect(service.feeds, initialFeeds);
    });
  });
}
