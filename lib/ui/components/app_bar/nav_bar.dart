import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../provider/feed/feeds_list_provider.dart';
import '../../../provider/theme/theme_provider.dart';
import '../../../util/const/ui/ui_constants.dart';
import 'nav_item.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  late final ScrollController _scrollController;

  final GlobalKey _viewportKey = GlobalKey();
  final Map<String, GlobalKey> _itemKeys = {};

  bool _restoreScheduled = false;
  String? _scheduledSelectedItemId;

  @override
  void initState() {
    super.initState();

    final provider = context.read<FeedsListProvider>();

    _scrollController = ScrollController(
      initialScrollOffset: provider.navBarScrollOffset,
    );

    _scrollController.addListener(_saveScrollOffset);
  }

  @override
  void dispose() {
    _saveScrollOffset();
    _scrollController.removeListener(_saveScrollOffset);
    _scrollController.dispose();
    super.dispose();
  }

  void _saveScrollOffset() {
    if (!_scrollController.hasClients) return;

    context.read<FeedsListProvider>().saveNavBarScrollOffset(
      _scrollController.offset,
    );
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

      if ((_scrollController.offset - target).abs() > 1) {
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
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FeedsListProvider>();
    final feedItems = provider.feeds;
    if (feedItems.isEmpty) {
      return const SizedBox(
        height: UIConstants.navBarHeight,
        child: Center(child: Text('Nenhum feed encontrado')),
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

    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        height: UIConstants.navBarHeight,
        child: SingleChildScrollView(
          key: _viewportKey,
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.navBarHorizontalPadding,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: UIConstants.navBarItemSpacing,
            children: [
              ...feedItems.map((item) {
                final id = item.id.toString();
                return NavItem(key: _keyForItem(id), feedItem: item);
              }),
              IconButton(
                onPressed: context.read<ThemeProvider>().toggleTheme,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
