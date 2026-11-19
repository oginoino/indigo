import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../model/feed_item.dart';
import '../../../provider/feed/feeds_list_provider.dart';
import '../../../util/const/app/app_strings.dart';
import '../../../util/const/ui/ui_constants.dart';

enum _HashtagMenuAction { togglePin }

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
                ],
              ),
            ),
          ),
          if (isSelected && hashtag != null)
            PopupMenuButton<_HashtagMenuAction>(
              tooltip: AppStrings.hashtagOptions,
              icon: const Icon(Icons.keyboard_arrow_down),
              onSelected: (_) async {
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
            )
          else if (isSelected)
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: UIConstants.navBarItemSpacing,
              ),
              child: Icon(Icons.keyboard_arrow_down),
            ),
        ],
      ),
    );
  }
}
