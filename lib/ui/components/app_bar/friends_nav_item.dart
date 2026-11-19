import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../model/feed_item.dart';
import '../../../model/party/user_profile.dart';
import '../../../provider/social/friends_provider.dart';
import '../../../util/const/app/app_strings.dart';
import '../../../util/const/ui/ui_constants.dart';
import '../../components/avatar.dart';
import '../../components/avatar_group.dart';

class FriendsNavItem extends StatelessWidget {
  const FriendsNavItem({required this.feedItem, super.key});

  final FeedItem feedItem;

  @override
  Widget build(BuildContext context) {
    final friends = context.watch<FriendsProvider>().friends;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AvatarGroup(
          size: AvatarSize.xSmall,
          members: [
            for (final friend in friends)
              AvatarGroupMember(
                imageProvider: _avatarProvider(friend),
                label: friend.displayName,
              ),
          ],
          emptyState: const _AddFriendsCta(),
        ),
        if (friends.isNotEmpty) ...[
          const SizedBox(width: UIConstants.spaceSm),
          Text(feedItem.name, textAlign: TextAlign.left),
        ],
      ],
    );
  }

  ImageProvider<Object>? _avatarProvider(UserProfile friend) {
    final avatarUrl = friend.avatarUrl;
    if (avatarUrl == null || avatarUrl.isEmpty) return null;
    return NetworkImage(avatarUrl);
  }
}

class _AddFriendsCta extends StatelessWidget {
  const _AddFriendsCta();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.person_add_alt_1_rounded,
          size: UIConstants.friendsNavCtaIconSize,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: UIConstants.spaceSm),
        Text(
          AppStrings.addFriends,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
