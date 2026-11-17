import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import '../service/persistence/persistence_service.dart';
import '../util/const/app/app_constants.dart';
import '../service/feed/feeds_list_service.dart';
import '../provider/theme/theme_provider.dart';

class DependencyInjection {
  DependencyInjection._();

  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await _initSharedPreferences();
    await _initAppConstants();
    await _initFeedItemService();
    await _initPersistenceService();
    await _initThemeProvider();
  }

  static Future<void> _initSharedPreferences() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    GetIt.instance.registerSingleton<SharedPreferences>(sharedPreferences);
  }

  static Future<void> _initAppConstants() async {
   final appConstants = AppConstants();
   GetIt.instance.registerSingleton<AppConstants>(appConstants);
  }

  static Future<void> _initFeedItemService() async {
    final feedItemService = FeedsListService();
    GetIt.instance.registerSingleton<FeedsListService>(feedItemService);
    
  }

  static Future<void> _initPersistenceService() async {
    final persistenceService = PersistenceService(GetIt.I<SharedPreferences>());
    GetIt.instance.registerSingleton<PersistenceService>(persistenceService);
  }

  static Future<void> _initThemeProvider() async {
    final themeProvider = ThemeProvider(GetIt.I<PersistenceService>());
    GetIt.instance.registerSingleton<ThemeProvider>(themeProvider);
  }
}


AppConstants get appConstants => GetIt.I<AppConstants>();
PersistenceService get persistenceService => GetIt.I<PersistenceService>();
ThemeProvider get themeProvider => GetIt.I<ThemeProvider>();
FeedsListService get feedItemsService => GetIt.I<FeedsListService>();
