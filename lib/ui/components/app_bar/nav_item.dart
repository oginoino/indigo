import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../model/feed_item.dart';
import '../../../provider/feed/feeds_list_provider.dart';
import '../../../util/const/ui/ui_constants.dart';

class NavItem extends StatelessWidget {
  const NavItem({required this.feedItem, this.onSelected, super.key});

  final FeedItem feedItem;
  final ValueChanged<String>? onSelected;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FeedsListProvider>();
    final itemId = feedItem.id.toString();
    final isSelected = provider.isFeedSelected(feedItem.id);
    final indicatorColor = isSelected
        ? DefaultTextStyle.of(context).style.color ?? Colors.transparent
        : Colors.transparent;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        context.read<FeedsListProvider>().selectFeed(feedItem.id);
        onSelected?.call(itemId);
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
                bottom: BorderSide(color: indicatorColor, width: 2),
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
