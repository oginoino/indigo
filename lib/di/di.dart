import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../service/app_data_service.dart';
import '../service/persistence/avatar_image_service.dart';
import '../service/persistence/persistence_service.dart';
import '../service/social_data_service.dart';

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
    if (!locator.isRegistered<AvatarImageService>()) {
      final storageDirectory = await getApplicationSupportDirectory();
      locator.registerSingleton<AvatarImageService>(
        AvatarImageService(
          preferences: sharedPreferences,
          storageDirectory: storageDirectory,
        ),
      );
    }
    if (!locator.isRegistered<AppDataService>()) {
      locator.registerSingleton<AppDataService>(AssetAppDataService());
    }
    if (!locator.isRegistered<SocialDataService>()) {
      locator.registerSingleton<SocialDataService>(AssetSocialDataService());
    }

    await locator<AppDataService>().load();
    await locator<SocialDataService>().load();
  }
}

PersistenceService get persistenceService =>
    GetIt.instance<PersistenceService>();

AvatarImageService get avatarImageService =>
    GetIt.instance<AvatarImageService>();

AppDataService get appDataService => GetIt.instance<AppDataService>();

SocialDataService get socialDataService => GetIt.instance<SocialDataService>();
