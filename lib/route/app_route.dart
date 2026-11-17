import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class AppRoute extends GoRoute {
  AppRoute(
    String path,
    Widget Function(BuildContext context, GoRouterState state) builder, {
    super.routes,
    bool useFade = true,
  }) : super(
         path: path,
         pageBuilder: (context, state) {
           final page = builder(context, state);
           if (!useFade) {
             return MaterialPage(key: state.pageKey, child: page);
           }

           return CustomTransitionPage(
             key: state.pageKey,
             child: page,
             transitionsBuilder:
                 (context, animation, secondaryAnimation, child) {
                   return FadeTransition(opacity: animation, child: child);
                 },
           );
         },
       );
}
