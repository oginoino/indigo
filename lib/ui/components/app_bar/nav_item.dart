import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../model/feed_item.dart';
import '../../../provider/feed/feeds_list_provider.dart';
import '../../../util/const/ui/ui_constants.dart';

class NavItem extends StatelessWidget {
  const NavItem({required this.feedItem, super.key});

  final FeedItem feedItem;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FeedsListProvider>();
    final isSelected = provider.isFeedSelected(feedItem.id);
    final indicatorColor = isSelected
        ? Theme.of(context).textTheme.bodyMedium?.color ??
              Theme.of(context).colorScheme.onSurface
        : Colors.transparent;

    return InkWell(
      borderRadius: BorderRadius.circular(UIConstants.navBarItemBorderRadius),
      onTap: () {
        context.read<FeedsListProvider>().selectFeed(feedItem.id);
        context.go(feedItem.route);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.navBarHorizontalPadding,
              vertical: UIConstants.navBarItemSpacing,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: indicatorColor,
                  width: UIConstants.navBarSelectedIndicatorThickness,
                ),
              ),
            ),
            child: Text(feedItem.name, textAlign: TextAlign.left),
          ),
          if (isSelected)
            const Icon(Icons.keyboard_arrow_down)
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}
