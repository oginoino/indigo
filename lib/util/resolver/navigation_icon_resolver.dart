import 'package:material_ui/material_ui.dart';

class NavigationIconResolver {
  NavigationIconResolver._();

  static const Map<String, IconData> _icons = {
    // Descobrir / Início
    'home': Icons.home_outlined,
    'home_rounded': Icons.home_outlined,
    'home_outlined': Icons.home_outlined,
    'discover': Icons.explore_outlined,
    'explore': Icons.explore_outlined,
    'explore_rounded': Icons.explore_outlined,

    // Vídeos
    'video': Icons.video_library_outlined,
    'videos': Icons.video_library_outlined,
    'video_library': Icons.video_library_outlined,
    'video_library_rounded': Icons.video_library_outlined,
    'video_library_outlined': Icons.video_library_outlined,

    // Busca
    'search': Icons.search_rounded,
    'search_rounded': Icons.search_rounded,

    // Criar
    'create': Icons.add_circle_outline_rounded,
    'add': Icons.add_circle_outline_rounded,
    'add_circle_outline_rounded': Icons.add_circle_outline_rounded,
    'add_circle_rounded': Icons.add_circle_outline_rounded,

    // Mensagens
    'messages': Icons.send_outlined,
    'send': Icons.send_outlined,
    'send_rounded': Icons.send_outlined,
    'send_outlined': Icons.send_outlined,

    // Perfil
    'profile': Icons.person_outline_rounded,
    'person': Icons.person_outline_rounded,
    'person_rounded': Icons.person_outline_rounded,
    'person_outline_rounded': Icons.person_outline_rounded,

    // Outros
    'settings': Icons.settings_outlined,
    'settings_outlined': Icons.settings_outlined,
    'notifications': Icons.notifications_outlined,
    'notifications_outlined': Icons.notifications_outlined,
    'favorite': Icons.favorite_border_rounded,
    'favorite_border_rounded': Icons.favorite_border_rounded,
    'bookmark': Icons.bookmark_border_rounded,
    'bookmark_border_rounded': Icons.bookmark_border_rounded,
  };

  static const Map<String, IconData> _activeIcons = {
    // Descobrir / Início
    'home': Icons.home_rounded,
    'home_rounded': Icons.home_rounded,
    'home_outlined': Icons.home_rounded,
    'discover': Icons.explore_rounded,
    'explore': Icons.explore_rounded,
    'explore_rounded': Icons.explore_rounded,

    // Vídeos
    'video': Icons.video_library_rounded,
    'videos': Icons.video_library_rounded,
    'video_library': Icons.video_library_rounded,
    'video_library_rounded': Icons.video_library_rounded,
    'video_library_outlined': Icons.video_library_rounded,

    // Busca
    'search': Icons.search_rounded,
    'search_rounded': Icons.search_rounded,

    // Criar
    'create': Icons.add_circle_rounded,
    'add': Icons.add_circle_rounded,
    'add_circle_outline_rounded': Icons.add_circle_rounded,
    'add_circle_rounded': Icons.add_circle_rounded,

    // Mensagens
    'messages': Icons.send_rounded,
    'send': Icons.send_rounded,
    'send_rounded': Icons.send_rounded,
    'send_outlined': Icons.send_rounded,

    // Perfil
    'profile': Icons.person_rounded,
    'person': Icons.person_rounded,
    'person_rounded': Icons.person_rounded,
    'person_outline_rounded': Icons.person_rounded,

    // Outros
    'settings': Icons.settings_rounded,
    'settings_outlined': Icons.settings_rounded,
    'notifications': Icons.notifications_rounded,
    'notifications_outlined': Icons.notifications_rounded,
    'favorite': Icons.favorite_rounded,
    'favorite_border_rounded': Icons.favorite_rounded,
    'bookmark': Icons.bookmark_rounded,
    'bookmark_border_rounded': Icons.bookmark_rounded,
  };

  static String _normalize(String name) {
    return name.trim().toLowerCase().replaceAll('-', '_');
  }

  static IconData resolve(String name) {
    return _icons[_normalize(name)] ?? Icons.circle_outlined;
  }

  static IconData resolveActive(String name) {
    final key = _normalize(name);
    return _activeIcons[key] ?? resolve(name);
  }
}
