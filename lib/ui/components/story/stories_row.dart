import 'package:material_ui/material_ui.dart';

import '../../../model/party/user_profile.dart';
import '../../../model/post/post.dart';
import '../../../util/const/app/app_strings.dart';
import '../../../util/const/ui/ui_constants.dart';
import '../avatar.dart';
import 'story_viewer.dart';

class StoriesRow extends StatelessWidget {
  const StoriesRow({
    required this.stories,
    required this.authorFor,
    this.currentUser,
    this.seenStoryIds = const <String>{},
    this.onStorySeen,
    super.key,
  });

  final List<Post> stories;
  final UserProfile? Function(Post post) authorFor;
  final UserProfile? currentUser;
  final Set<String> seenStoryIds;
  final ValueChanged<Post>? onStorySeen;

  @override
  Widget build(BuildContext context) {
    final ownRoleId = currentUser?.platformUserRoleId;
    final otherGroups = _groupsByAuthor()
        .where((group) => group.authorRoleId != ownRoleId)
        .toList(growable: false);
    // Perfis com stories não vistos primeiro; totalmente vistos no final.
    // A ordem original é preservada dentro de cada grupo.
    final groups = <_StoryGroup>[
      ...otherGroups.where((group) => !_isAllSeen(group)),
      ...otherGroups.where(_isAllSeen),
    ];
    final orderedStories = <Post>[for (final group in groups) ...group.stories];

    final items = <Widget>[];
    if (currentUser case final user?) {
      items.add(
        _StoryItem(
          label: AppStrings.yourStory,
          imageProvider: _avatarProvider(user),
          isOwn: true,
        ),
      );
    }
    var startIndex = 0;
    for (final group in groups) {
      final firstIndex = startIndex;
      startIndex += group.stories.length;
      final unseenOffset = group.stories.indexWhere(
        (story) => !seenStoryIds.contains(story.id),
      );
      final openIndex = unseenOffset == -1
          ? firstIndex
          : firstIndex + unseenOffset;
      final allSeen = unseenOffset == -1;
      items.add(
        _StoryItem(
          label: group.author?.displayName ?? AppStrings.unknownPostAuthor,
          imageProvider: _avatarProvider(group.author),
          isSeen: allSeen,
          onTap: () => _openStory(context, orderedStories, openIndex),
        ),
      );
    }

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

  bool _isAllSeen(_StoryGroup group) =>
      group.stories.every((story) => seenStoryIds.contains(story.id));

  List<_StoryGroup> _groupsByAuthor() {
    final order = <String>[];
    final storiesByAuthor = <String, List<Post>>{};
    for (final story in stories) {
      final roleId = story.authorPartyRoleId;
      storiesByAuthor
          .putIfAbsent(roleId, () {
            order.add(roleId);
            return <Post>[];
          })
          .add(story);
    }

    return [
      for (final roleId in order)
        _StoryGroup(
          authorRoleId: roleId,
          author: authorFor(storiesByAuthor[roleId]!.first),
          stories: List.unmodifiable(storiesByAuthor[roleId]!),
        ),
    ];
  }

  void _openStory(BuildContext context, List<Post> orderedStories, int index) {
    Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        opaque: true,
        transitionDuration: UIConstants.storyViewerTransitionDuration,
        pageBuilder: (context, animation, secondaryAnimation) => StoryViewer(
          stories: orderedStories,
          authorFor: authorFor,
          initialIndex: index,
          seenStoryIds: seenStoryIds,
          onStorySeen: onStorySeen,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  static ImageProvider<Object>? _avatarProvider(UserProfile? user) {
    final avatarUrl = user?.avatarUrl;
    if (avatarUrl == null || avatarUrl.isEmpty) return null;
    return NetworkImage(avatarUrl);
  }
}

class _StoryGroup {
  const _StoryGroup({
    required this.authorRoleId,
    required this.author,
    required this.stories,
  });

  final String authorRoleId;
  final UserProfile? author;
  final List<Post> stories;
}

class _StoryItem extends StatelessWidget {
  const _StoryItem({
    required this.label,
    required this.imageProvider,
    this.isOwn = false,
    this.isSeen = false,
    this.onTap,
  });

  final String label;
  final ImageProvider<Object>? imageProvider;
  final bool isOwn;
  final bool isSeen;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarDiameter =
        UIConstants.storyAvatarSize -
        (UIConstants.storyRingWidth + UIConstants.storyRingGap) * 2;

    return SizedBox(
      width: UIConstants.storyItemWidth,
      child: Semantics(
        button: onTap != null,
        label: onTap == null
            ? label
            : AppStrings.openStory.replaceAll('{name}', label),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(UIConstants.postMediaRadius),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StoryRing(
                isOwn: isOwn,
                isSeen: isSeen,
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
        ),
      ),
    );
  }
}

class _StoryRing extends StatelessWidget {
  const _StoryRing({
    required this.child,
    required this.isOwn,
    this.isSeen = false,
  });

  final Widget child;
  final bool isOwn;
  final bool isSeen;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final gradient = isOwn || isSeen
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