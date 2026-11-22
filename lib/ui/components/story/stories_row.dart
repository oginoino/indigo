import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../model/party/user_profile.dart';
import '../../../model/post/post.dart';
import '../../../provider/story/story_seen_provider.dart';
import '../../../util/const/app/app_strings.dart';
import '../../../util/const/ui/ui_constants.dart';
import '../avatar.dart';
import 'story_viewer.dart';

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
    final seen = context.watch<StorySeenProvider>();
    final ownRoleId = currentUser?.platformUserRoleId;
    final otherGroups = _groupsByAuthor()
        .where((group) => group.authorRoleId != ownRoleId)
        .toList(growable: false);
    // Perfis com stories não vistos primeiro; totalmente vistos no final.
    // A ordem original é preservada dentro de cada grupo.
    final groups = <_StoryGroup>[
      ...otherGroups.where((group) => !seen.hasSeenAll(group.stories)),
      ...otherGroups.where((group) => seen.hasSeenAll(group.stories)),
    ];
    final orderedStories = <Post>[for (final group in groups) ...group.stories];

    // Stories próprios do usuário (para ring e tap no avatar próprio).
    final ownStories = ownRoleId == null
        ? const <Post>[]
        : stories
            .where((s) => s.authorPartyRoleId == ownRoleId)
            .toList(growable: false);

    final items = <Widget>[];
    if (currentUser case final user?) {
      items.add(
        _StoryItem(
          label: AppStrings.yourStory,
          imageProvider: _avatarProvider(user),
          isOwn: true,
          hasOwnStory: ownStories.isNotEmpty,
          onTap: ownStories.isNotEmpty
              ? () => _openStory(context, ownStories, 0)
              : null,
        ),
      );
    }
    var startIndex = 0;
    for (final group in groups) {
      final firstIndex = startIndex;
      startIndex += group.stories.length;
      final unseenOffset = seen.firstUnseenIndex(group.stories);
      final allSeen = unseenOffset == -1;
      final openIndex = allSeen ? firstIndex : firstIndex + unseenOffset;
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
    this.hasOwnStory = false,
    this.onTap,
  });

  final String label;
  final ImageProvider<Object>? imageProvider;
  final bool isOwn;
  final bool isSeen;
  final bool hasOwnStory;
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
                hasOwnStory: hasOwnStory,
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
    this.hasOwnStory = false,
    this.isSeen = false,
  });

  final Widget child;
  final bool isOwn;
  final bool hasOwnStory;
  final bool isSeen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Ring com gradiente: outros usuários com stories não vistos, ou o próprio
    // usuário quando tem stories publicados.
    final showGradient = isOwn ? hasOwnStory : (!isSeen);
    final gradient = showGradient
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary,
              colorScheme.tertiary,
              colorScheme.secondary,
            ],
          )
        : null;

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
          color: theme.scaffoldBackgroundColor,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: UIConstants.storyAddBadgeSize,
      height: UIConstants.storyAddBadgeSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.primary,
        border: Border.all(
          color: theme.scaffoldBackgroundColor,
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