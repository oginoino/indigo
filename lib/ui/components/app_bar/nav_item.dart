import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../model/feed_item.dart';
import '../../../provider/feed/feeds_list_provider.dart';
import '../../../util/const/app/app_strings.dart';
import '../../../util/const/app/feed_constants.dart';
import '../../../util/const/ui/ui_constants.dart';
import 'friends_nav_item.dart';
import 'nav_motion.dart';

enum _HashtagMenuAction { togglePin }

class NavItem extends StatefulWidget {
  const NavItem({required this.feedItem, super.key});

  final FeedItem feedItem;

  @override
  State<NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<NavItem> {
  bool _pressed = false;
  bool _menuOpen = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<FeedsListProvider>();
    final feedItem = widget.feedItem;
    final isSelected = provider.isFeedSelected(feedItem.id);
    final hashtag = feedItem.hashtag;

    final selectedColor =
        theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface;
    final idleColor = theme.colorScheme.onSurfaceVariant;
    final baseStyle = DefaultTextStyle.of(context).style;
    final thickness = UIConstants.navBarSelectedIndicatorThickness;

    final label = feedItem.route == FeedConstants.friendsFeedRoute
        ? FriendsNavItem(feedItem: feedItem)
        : Text(feedItem.name, textAlign: TextAlign.left);

    final Widget? trailing;
    if (isSelected && hashtag != null) {
      trailing = PopupMenuButton<_HashtagMenuAction>(
        key: const ValueKey('nav-trailing-menu'),
        tooltip: AppStrings.hashtagOptions,
        icon: _Chevron(open: _menuOpen),
        onOpened: () => setState(() => _menuOpen = true),
        onCanceled: () => setState(() => _menuOpen = false),
        onSelected: (_) async {
          setState(() => _menuOpen = false);
          try {
            await provider.toggleHashtagPin(hashtag);
          } catch (_) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(AppStrings.hashtagPinSaveFailed)),
            );
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: _HashtagMenuAction.togglePin,
            child: Row(
              children: [
                Icon(
                  provider.isHashtagPinned(hashtag.id)
                      ? Icons.push_pin_outlined
                      : Icons.push_pin,
                ),
                const SizedBox(width: UIConstants.spaceSm),
                Flexible(
                  child: Text(
                    provider.isHashtagPinned(hashtag.id)
                        ? AppStrings.unpinHashtag
                        : AppStrings.pinHashtag,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else if (isSelected) {
      trailing = const Padding(
        key: ValueKey('nav-trailing-chevron'),
        padding: EdgeInsets.symmetric(horizontal: UIConstants.navBarItemSpacing),
        child: _Chevron(open: false),
      );
    } else {
      trailing = null;
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: UIConstants.navBarHeight),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(
              UIConstants.navBarItemBorderRadius,
            ),
            onHighlightChanged: (value) {
              if (_pressed != value) setState(() => _pressed = value);
            },
            onTap: () {
              if (!isSelected) HapticFeedback.selectionClick();
              context.read<FeedsListProvider>().selectFeed(feedItem.id);
              context.go(feedItem.route);
            },
            // Leve "afundar" ao pressionar, como feedback tátil visual.
            child: AnimatedScale(
              scale: _pressed ? 0.95 : 1,
              duration: NavMotion.of(context, NavMotion.fast),
              curve: Curves.easeOut,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: UIConstants.navBarHeight,
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          UIConstants.navBarHorizontalPadding,
                          UIConstants.navBarItemSpacing,
                          UIConstants.navBarHorizontalPadding,
                          UIConstants.navBarItemSpacing + thickness,
                        ),
                        // A cor do texto faz transição suave entre os estados.
                        // O peso da fonte não muda para não "pular" o layout.
                        child: AnimatedDefaultTextStyle(
                          duration: NavMotion.of(context, NavMotion.medium),
                          curve: NavMotion.emphasized,
                          style: baseStyle.copyWith(
                            color: isSelected ? selectedColor : idleColor,
                          ),
                          child: label,
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: _SelectionIndicator(
                          selected: isSelected,
                          color: selectedColor,
                          thickness: thickness,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // O botão de opções entra e sai com fade + escala, e o espaço
          // ocupado por ele anima em vez de "estalar".
          AnimatedSize(
            duration: NavMotion.of(context, NavMotion.medium),
            curve: NavMotion.emphasized,
            alignment: Alignment.centerLeft,
            child: AnimatedSwitcher(
              duration: NavMotion.of(context, NavMotion.medium),
              switchInCurve: NavMotion.emphasized,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              ),
              child:
                  trailing ??
                  const SizedBox.shrink(key: ValueKey('nav-trailing-empty')),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sublinhado que cresce do centro para as bordas ao selecionar o item.
class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({
    required this.selected,
    required this.color,
    required this.thickness,
  });

  final bool selected;
  final Color color;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: selected ? 1 : 0),
      duration: NavMotion.of(context, NavMotion.medium),
      curve: NavMotion.emphasized,
      builder: (context, factor, _) => FractionallySizedBox(
        widthFactor: factor,
        child: Container(
          height: thickness,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(thickness),
          ),
        ),
      ),
    );
  }
}

/// Seta que gira 180° enquanto o menu de opções está aberto.
class _Chevron extends StatelessWidget {
  const _Chevron({required this.open});

  final bool open;

  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      turns: open ? 0.5 : 0,
      duration: NavMotion.of(context, NavMotion.medium),
      curve: NavMotion.emphasized,
      child: const Icon(Icons.keyboard_arrow_down),
    );
  }
}