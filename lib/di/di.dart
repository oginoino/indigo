import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../service/app_data_service.dart';
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
    if (!locator.isRegistered<AppDataService>()) {
      locator.registerSingleton<AppDataService>(AssetAppDataService());
    }

    await locator<AppDataService>().load();
  }
}

PersistenceService get persistenceService =>
    GetIt.instance<PersistenceService>();

AppDataService get appDataService => GetIt.instance<AppDataService>();
