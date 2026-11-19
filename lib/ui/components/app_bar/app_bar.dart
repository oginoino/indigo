import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../util/const/app/app_strings.dart';
import '../../../util/const/ui/ui_constants.dart';
import '../avatar.dart';
import 'nav_bar.dart';
import 'nav_motion.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({this.floating = false, this.snap = false, super.key});

  final bool floating;
  final bool snap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      floating: floating,
      snap: snap,
      backgroundColor:
          theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
      title: const _StarTitle(),
      leadingWidth: UIConstants.appBarLeadingWidth,
      toolbarHeight: UIConstants.appBarToolbarHeight,
      leading: const Center(child: Avatar(size: AvatarSize.small)),
      actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(UIConstants.navBarHeight),
        child: NavBar(),
      ),
    );
  }
}

/// Estrela do título: ao tocar, "brilha" (giro de 72° + pulso de escala) e
/// rola o feed de volta ao topo.
///
/// Como a estrela tem simetria de 5 pontas, girar 72° termina exatamente na
/// mesma aparência, então a animação acaba sem "salto" visual.
class _StarTitle extends StatefulWidget {
  const _StarTitle();

  @override
  State<_StarTitle> createState() => _StarTitleState();
}

class _StarTitleState extends State<_StarTitle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: NavMotion.slow + NavMotion.fast,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    HapticFeedback.lightImpact();

    if (!MediaQuery.disableAnimationsOf(context)) {
      _controller.forward(from: 0);
    }

    // Só funciona se o feed usar o PrimaryScrollController (padrão do
    // CustomScrollView sem controller próprio); caso contrário, não faz nada.
    final scroll = PrimaryScrollController.maybeOf(context);
    if (scroll != null && scroll.hasClients && scroll.offset > 0) {
      scroll.animateTo(
        0,
        duration: NavMotion.of(context, NavMotion.slow),
        curve: NavMotion.emphasized,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: AppStrings.scrollToTopLabel,
      onPressed: _onTap,
      color: Theme.of(context).colorScheme.onSurface,
      icon: AnimatedBuilder(
        animation: _controller,
        child: const Icon(Icons.star),
        builder: (context, child) {
          final t = _controller.value;
          final eased = Curves.easeOutCubic.transform(t);

          return Transform.rotate(
            angle: eased * 2 * math.pi / 5,
            child: Transform.scale(
              scale: 1 + 0.3 * math.sin(math.pi * t),
              child: child,
            ),
          );
        },
      ),
    );
  }
}