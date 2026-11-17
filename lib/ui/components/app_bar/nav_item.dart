
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../provider/feed/feeds_list_provider.dart';
import '../../../model/feed_item.dart';

class NavItem extends StatelessWidget {
  final FeedItem feedItem;
  final ValueChanged<String>? onSelected;

  const NavItem({
    super.key,
    required this.feedItem,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FeedsListProvider>();
    final String itemId = feedItem.id.toString();
    final bool isSelected = provider.isFeedSelected(itemId);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        context.read<FeedsListProvider>().selectFeed(itemId);
        onSelected?.call(itemId);
      },
      child: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isSelected
                      ? Colors.black
                      : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Text(
              feedItem.name,
              textAlign: TextAlign.left,
            ),
          
        ),
        if (isSelected)
          const Icon(Icons.keyboard_arrow_down)
        else
          const SizedBox.shrink(),
      ],
    ));
  }
}
