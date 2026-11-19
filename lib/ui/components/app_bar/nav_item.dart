import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../model/feed_item.dart';
import '../../../provider/feed/feeds_list_provider.dart';
import '../../../util/const/app/app_strings.dart';
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

    final hashtag = feedItem.hashtag;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: UIConstants.navBarHeight),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(
              UIConstants.navBarItemBorderRadius,
            ),
            onTap: () {
              context.read<FeedsListProvider>().selectFeed(feedItem.id);
              context.go(feedItem.route);
            },
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: UIConstants.navBarHeight,
              ),
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
                  if (isSelected) const Icon(Icons.keyboard_arrow_down),
                ],
              ),
            ),
          ),
          if (hashtag != null)
            IconButton(
              tooltip: provider.isHashtagPinned(hashtag.id)
                  ? AppStrings.unpinHashtag
                  : AppStrings.pinHashtag,
              constraints: const BoxConstraints(
                minWidth: UIConstants.navBarHeight,
                minHeight: UIConstants.navBarHeight,
              ),
              onPressed: () async {
                try {
                  await provider.toggleHashtagPin(hashtag);
                } catch (_) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(AppStrings.hashtagPinSaveFailed),
                    ),
                  );
                }
              },
              icon: Icon(
                provider.isHashtagPinned(hashtag.id)
                    ? Icons.push_pin
                    : Icons.push_pin_outlined,
              ),
            ),
        ],
      ),
    );
  }
}
