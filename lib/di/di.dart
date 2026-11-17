import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../service/feed/feeds_list_service.dart';
import '../service/persistence/persistence_service.dart';

class DependencyInjection {
  const DependencyInjection._();

  static Future<void> init() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final locator = GetIt.instance;

    locator.registerSingleton<SharedPreferences>(sharedPreferences);
    locator.registerSingleton<PersistenceService>(
      PersistenceService(sharedPreferences),
    );
    locator.registerSingleton<FeedsListService>(const FeedsListService());
  }
}

PersistenceService get persistenceService =>
    GetIt.instance<PersistenceService>();

FeedsListService get feedsListService => GetIt.instance<FeedsListService>();
