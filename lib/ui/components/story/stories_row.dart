import 'package:material_ui/material_ui.dart';

import '../../../model/party/user_profile.dart';
import '../../../model/post/post.dart';
import '../../../util/const/app/app_strings.dart';
import '../../../util/const/ui/ui_constants.dart';
import '../avatar.dart';

class StoriesRow extends StatelessWidget {
  const StoriesRow({
    required this.stories,
    required this.authorFor,
    this.currentUser,
    super.key,
  });

  final List<Post> stories;
  final UserProfile? Function(Post post) authorFor;
  final UserProfile? currentUser;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      if (currentUser case final user?)
        _StoryItem(
          label: AppStrings.yourStory,
          imageProvider: _avatarProvider(user),
          isOwn: true,
        ),
      for (final story in stories)
        _StoryItem(
          label: authorFor(story)?.displayName ?? AppStrings.unknownPostAuthor,
          imageProvider: _avatarProvider(authorFor(story)),
        ),
    ];

    if (items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: UIConstants.storyRowHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.postCardHorizontalInset,
          vertical: UIConstants.storyRowVerticalPadding,
        ),
        itemCount: items.length,
        separatorBuilder: (_, _) =>
            const SizedBox(width: UIConstants.storyItemSpacing),
        itemBuilder: (context, index) => items[index],
      ),
    );
  }

  static ImageProvider<Object>? _avatarProvider(UserProfile? user) {
    final avatarUrl = user?.avatarUrl;
    if (avatarUrl == null || avatarUrl.isEmpty) return null;
    return NetworkImage(avatarUrl);
  }
}

class _StoryItem extends StatelessWidget {
  const _StoryItem({
    required this.label,
    required this.imageProvider,
    this.isOwn = false,
  });

  final String label;
  final ImageProvider<Object>? imageProvider;
  final bool isOwn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarDiameter =
        UIConstants.storyAvatarSize -
        (UIConstants.storyRingWidth + UIConstants.storyRingGap) * 2;

    return SizedBox(
      width: UIConstants.storyItemWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StoryRing(
            isOwn: isOwn,
            child: Avatar(
              diameter: avatarDiameter,
              imageProvider: imageProvider,
              useSavedImage: false,
              badge: isOwn ? const _AddBadge() : null,
            ),
          ),
          const SizedBox(height: UIConstants.storyLabelSpacing),
          Text(
            label,
            maxLines: UIConstants.storyLabelMaxLines,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _StoryRing extends StatelessWidget {
  const _StoryRing({required this.child, required this.isOwn});

  final Widget child;
  final bool isOwn;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final gradient = isOwn
        ? null
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary,
              colorScheme.tertiary,
              colorScheme.secondary,
            ],
          );

    return Container(
      width: UIConstants.storyAvatarSize,
      height: UIConstants.storyAvatarSize,
      padding: const EdgeInsets.all(UIConstants.storyRingWidth),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient,
        color: gradient == null ? colorScheme.outlineVariant : null,
      ),
      child: Container(
        padding: const EdgeInsets.all(UIConstants.storyRingGap),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: child,
      ),
    );
  }
}

class _AddBadge extends StatelessWidget {
  const _AddBadge();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: UIConstants.storyAddBadgeSize,
      height: UIConstants.storyAddBadgeSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.primary,
        border: Border.all(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: UIConstants.avatarGroupRingWidth,
        ),
      ),
      child: Icon(
        Icons.add,
        size: UIConstants.storyAddIconSize,
        color: colorScheme.onPrimary,
      ),
    );
  }
}
