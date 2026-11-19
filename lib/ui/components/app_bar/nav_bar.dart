import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../provider/feed/feeds_list_provider.dart';
import '../../../provider/theme/theme_provider.dart';
import '../../../util/const/app/app_strings.dart';
import '../../../util/const/ui/ui_constants.dart';
import 'nav_item.dart';
import 'nav_motion.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  /// A entrada em cascata toca só na primeira vez que a barra aparece na
  /// sessão, para não repetir a cada troca de página.
  static bool _introPlayed = false;

  /// Distância (em px) usada para esmaecer as bordas da lista.
  static const double _edgeFadeDistance = 24;

  /// Largura (em px) da faixa de esmaecimento nas bordas.
  static const double _edgeFadeWidth = 20;

  late final ScrollController _scrollController;
  late final bool _playIntro;

  final GlobalKey _viewportKey = GlobalKey();
  final Map<String, GlobalKey> _itemKeys = {};

  /// (esquerda, direita): intensidade 0..1 do esmaecimento de cada borda.
  final ValueNotifier<(double, double)> _edges = ValueNotifier((0, 0));

  bool _restoreScheduled = false;
  bool _edgesUpdateScheduled = false;
  String? _scheduledSelectedItemId;

  /// Índice do item sendo arrastado (null quando não há arraste).
  int? _draggingIndex;

  @override
  void initState() {
    super.initState();

    _playIntro = !_introPlayed;
    _introPlayed = true;

    final provider = context.read<FeedsListProvider>();

    _scrollController = ScrollController(
      initialScrollOffset: provider.navBarScrollOffset,
    );

    _scrollController
      ..addListener(_saveScrollOffset)
      ..addListener(_scheduleEdgesUpdate);
  }

  @override
  void dispose() {
    _saveScrollOffset();
    _scrollController
      ..removeListener(_saveScrollOffset)
      ..removeListener(_scheduleEdgesUpdate)
      ..dispose();
    _edges.dispose();
    super.dispose();
  }

  void _saveScrollOffset() {
    if (!_scrollController.hasClients) return;

    context.read<FeedsListProvider>().saveNavBarScrollOffset(
      _scrollController.offset,
    );
  }

  /// Atualiza o esmaecimento das bordas depois do frame atual, porque as
  /// notificações de métricas podem chegar durante o layout.
  void _scheduleEdgesUpdate() {
    if (_edgesUpdateScheduled) return;

    _edgesUpdateScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _edgesUpdateScheduled = false;

      if (!mounted || !_scrollController.hasClients) return;

      final position = _scrollController.position;
      if (!position.hasContentDimensions) return;

      final left = (position.pixels / _edgeFadeDistance)
          .clamp(0.0, 1.0)
          .toDouble();
      final right = ((position.maxScrollExtent - position.pixels) /
              _edgeFadeDistance)
          .clamp(0.0, 1.0)
          .toDouble();

      _edges.value = (left, right);
    });
  }

  GlobalKey _keyForItem(String id) {
    return _itemKeys.putIfAbsent(id, () => GlobalKey());
  }

  void _restoreScrollOffset() {
    if (_restoreScheduled) return;

    _restoreScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreScheduled = false;

      if (!mounted || !_scrollController.hasClients) return;

      final savedOffset = context.read<FeedsListProvider>().navBarScrollOffset;

      final maxExtent = _scrollController.position.maxScrollExtent;

      final target = savedOffset.clamp(0.0, maxExtent);

      if ((_scrollController.offset - target).abs() >
          UIConstants.navBarScrollTolerance) {
        _scrollController.jumpTo(target);
      }
    });
  }

  void _scrollToItem(String id) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      final itemContext = _itemKeys[id]?.currentContext;
      final viewportContext = _viewportKey.currentContext;

      if (itemContext == null || viewportContext == null) {
        return;
      }

      final itemBox = itemContext.findRenderObject() as RenderBox?;
      final viewportBox = viewportContext.findRenderObject() as RenderBox?;

      if (itemBox == null ||
          viewportBox == null ||
          !itemBox.hasSize ||
          !viewportBox.hasSize) {
        return;
      }

      final itemPosition = itemBox.localToGlobal(Offset.zero);
      final viewportPosition = viewportBox.localToGlobal(Offset.zero);

      final itemLeft = itemPosition.dx;
      final itemRight = itemLeft + itemBox.size.width;
      final viewportLeft = viewportPosition.dx;
      final viewportRight = viewportLeft + viewportBox.size.width;

      double delta = 0;

      if (itemLeft < viewportLeft) {
        delta = itemLeft - viewportLeft;
      } else if (itemRight > viewportRight) {
        delta = itemRight - viewportRight;
      } else {
        return;
      }

      final maxExtent = _scrollController.position.maxScrollExtent;

      final target = (_scrollController.offset + delta).clamp(0.0, maxExtent);

      _scrollController.animateTo(
        target,
        duration: UIConstants.navBarScrollDuration,
        curve: Curves.easeInOut,
      );
    });
  }

  /// Item "levantado" enquanto é arrastado.
  ///
  /// Tudo é derivado do valor da animação do framework (0 → 1 ao pegar,
  /// 1 → 0 ao soltar), então o "pouso" é tão suave quanto a subida: o item
  /// cresce de leve, ganha fundo tingido com a cor primária, um contorno
  /// fino e duas sombras em camadas (uma ampla e difusa, outra curta e
  /// definida) que dão sensação de profundidade.
  Widget _buildDragProxy(
    Widget child,
    int index,
    Animation<double> animation,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final radius = BorderRadius.circular(UIConstants.navBarItemBorderRadius);
    final fill = Color.alphaBlend(
      colors.primary.withValues(alpha: 0.08),
      colors.surfaceContainerHigh,
    );

    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(animation.value);

        return Transform.scale(
          scale: reduceMotion ? 1 : 1 + 0.05 * t,
          child: Material(
            type: MaterialType.transparency,
            child: Stack(
              // Sem corte, para a sombra poder se espalhar para fora.
              clipBehavior: Clip.none,
              children: [
                // O destaque ignora o espaçamento à direita do item, para
                // o conteúdo ficar centralizado dentro do "cartão".
                Positioned.fill(
                  right: UIConstants.navBarItemSpacing,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color.lerp(Colors.transparent, fill, t),
                      borderRadius: radius,
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.30 * t),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withValues(alpha: 0.16 * t),
                          blurRadius: 20 * t,
                          offset: Offset(0, 8 * t),
                        ),
                        BoxShadow(
                          color: theme.shadowColor.withValues(alpha: 0.10 * t),
                          blurRadius: 4 * t,
                          offset: Offset(0, 1 * t),
                        ),
                      ],
                    ),
                  ),
                ),
                child!,
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FeedsListProvider>();
    final feedItems = provider.feeds;
    if (feedItems.isEmpty) {
      return const SizedBox(
        height: UIConstants.navBarHeight,
        child: Center(child: Text(AppStrings.noFeedsAvailable)),
      );
    }

    final ids = feedItems.map((item) => item.id.toString()).toSet();
    _itemKeys.removeWhere((id, key) => !ids.contains(id));
    _restoreScrollOffset();

    final selectedId = provider.selectedFeed?.id.toString();
    if (selectedId != null && selectedId != _scheduledSelectedItemId) {
      _scheduledSelectedItemId = selectedId;
      _scrollToItem(selectedId);
    }

    final children = <Widget>[
      for (var index = 0; index < feedItems.length; index++)
        ReorderableDelayedDragStartListener(
          key: _keyForItem(feedItems[index].id.toString()),
          index: index,
          enabled: provider.isFeedReorderable(feedItems[index]),
          child: _DragDim(
            dimmed: _draggingIndex != null && _draggingIndex != index,
            child: _IntroReveal(
              index: index,
              enabled: _playIntro,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: UIConstants.navBarItemSpacing,
                ),
                child: NavItem(feedItem: feedItems[index]),
              ),
            ),
          ),
        ),
      IconButton(
        key: const ValueKey('nav-bar-theme-toggle'),
        onPressed: context.read<ThemeProvider>().toggleTheme,
        icon: const Icon(Icons.add),
      ),
    ];

    final list = ReorderableListView(
      key: _viewportKey,
      scrollDirection: Axis.horizontal,
      scrollController: _scrollController,
      buildDefaultDragHandles: false,
      proxyDecorator: _buildDragProxy,
      onReorderStart: (index) {
        HapticFeedback.mediumImpact();
        setState(() => _draggingIndex = index);
      },
      onReorderEnd: (_) {
        HapticFeedback.lightImpact();
        if (!mounted) return;
        setState(() => _draggingIndex = null);
      },
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.navBarHorizontalPadding,
      ),
      onReorderItem: (oldIndex, newIndex) async {
        if (oldIndex >= feedItems.length) return;

        final targetIndex = newIndex.clamp(0, feedItems.length - 1);
        try {
          await provider.reorderFeeds(oldIndex, targetIndex);
        } catch (_) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.navFeedOrderSaveFailed)),
          );
        }
      },
      children: children,
    );

    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        height: UIConstants.navBarHeight,
        child: NotificationListener<ScrollMetricsNotification>(
          onNotification: (_) {
            _scheduleEdgesUpdate();
            return false;
          },
          // Esmaece as bordas onde ainda há conteúdo rolável, sinalizando que
          // a barra continua para o lado.
          child: ValueListenableBuilder<(double, double)>(
            valueListenable: _edges,
            child: list,
            builder: (context, edges, list) {
              final (left, right) = edges;

              return ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (bounds) {
                  final fade = bounds.width <= 0
                      ? 0.0
                      : (_edgeFadeWidth / bounds.width)
                            .clamp(0.0, 0.5)
                            .toDouble();

                  return LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 1 - left),
                      Colors.black,
                      Colors.black,
                      Colors.black.withValues(alpha: 1 - right),
                    ],
                    stops: [0, fade, 1 - fade, 1],
                  ).createShader(bounds);
                },
                child: list,
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Entrada em cascata dos itens: fade + leve deslocamento vertical, com
/// atraso crescente por posição (limitado aos primeiros itens).
class _IntroReveal extends StatelessWidget {
  const _IntroReveal({
    required this.index,
    required this.enabled,
    required this.child,
  });

  final int index;
  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!enabled || MediaQuery.disableAnimationsOf(context)) return child;

    final stagger = index.clamp(0, 6).toInt();
    final delayMs = stagger * 50;
    final totalMs = 320 + delayMs;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: totalMs),
      curve: Interval(delayMs / totalMs, 1, curve: Curves.easeOutCubic),
      child: child,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 6 * (1 - t)), child: child),
      ),
    );
  }
}

/// Esmaece levemente os itens que não estão sendo arrastados, para focar a
/// atenção no item "levantado".
class _DragDim extends StatelessWidget {
  const _DragDim({required this.dimmed, required this.child});

  final bool dimmed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: dimmed ? 0.5 : 1,
      duration: NavMotion.of(context, NavMotion.medium),
      curve: NavMotion.emphasized,
      child: child,
    );
  }
}