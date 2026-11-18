import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../service/bottom_navigation_bar/bottom_navigation_bar_list_service.dart';
import '../service/feed/feeds_list_service.dart';
import '../service/persistence/persistence_service.dart';

class DependencyInjection {
  const DependencyInjection._();

  static Future<void> init() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final locator = GetIt.instance;

    if (!locator.isRegistered<SharedPreferences>()) {
      locator.registerSingleton<SharedPreferences>(sharedPreferences);
    }
    if (!locator.isRegistered<PersistenceService>()) {
      locator.registerSingleton<PersistenceService>(
        PersistenceService(sharedPreferences),
      );
    }
    if (!locator.isRegistered<FeedsListService>()) {
      locator.registerSingleton<FeedsListService>(FeedsListService());
    }
    if (!locator.isRegistered<BottomNavigationBarListService>()) {
      locator.registerSingleton<BottomNavigationBarListService>(
        const AppBottomNavigationBarListService(),
      );
    }

    await locator<FeedsListService>().getFeedsList();
  }
}

PersistenceService get persistenceService =>
    GetIt.instance<PersistenceService>();

FeedsListService get feedsListService => GetIt.instance<FeedsListService>();
BottomNavigationBarListService get bottomNavigationBarListService =>
    GetIt.instance<BottomNavigationBarListService>();
