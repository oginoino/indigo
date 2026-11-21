import 'package:material_ui/material_ui.dart';

import '../../../model/post/post.dart';
import '../../../util/const/app/app_strings.dart';
import '../../../util/const/ui/ui_constants.dart';
import '../../theme/media_overlay_theme.dart';
import 'animated_engagement_icon.dart';

enum PostEngagementLayout { horizontal, vertical }

class PostEngagementBar extends StatelessWidget {
  const PostEngagementBar({
    required this.post,
    this.layout = PostEngagementLayout.horizontal,
    this.onMedia = false,
    this.onComment,
    this.onLike,
    this.onRepost,
    this.onSave,
    super.key,
  });

  final Post post;
  final PostEngagementLayout layout;
  final bool onMedia;
  final VoidCallback? onComment;
  final VoidCallback? onLike;
  final VoidCallback? onRepost;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaTheme = MediaOverlayTheme.of(context);
    final inactiveColor = onMedia
        ? mediaTheme.foregroundColor
        : theme.colorScheme.onSurfaceVariant;
    final likeColor = post.engagement.viewer.isReacted
        ? onMedia
              ? mediaTheme.likedColor
              : theme.colorScheme.primary
        : inactiveColor;
    final saveColor = post.engagement.viewer.isSaved
        ? onMedia
              ? mediaTheme.foregroundColor
              : theme.colorScheme.primary
        : inactiveColor;

    final metrics = [
      _EngagementMetric(
        layout: layout,
        onMedia: onMedia,
        icon: Icons.mode_comment_outlined,
        label: AppStrings.postComments,
        count: post.engagement.commentCount,
        color: inactiveColor,
        onPressed: onComment,
        effect: EngagementEffect.wiggle,
        playOnTap: true,
      ),
      _EngagementMetric(
        layout: layout,
        onMedia: onMedia,
        icon: post.engagement.viewer.isReacted
            ? Icons.favorite
            : Icons.favorite_border,
        label: AppStrings.postLikes,
        count: post.engagement.reactionCount,
        color: likeColor,
        onPressed: onLike,
        effect: EngagementEffect.pop,
        isActive: post.engagement.viewer.isReacted,
        playOnTap: true,
      ),
      _EngagementMetric(
        layout: layout,
        onMedia: onMedia,
        icon: Icons.repeat,
        label: AppStrings.postReposts,
        count: post.engagement.shareCount,
        color: inactiveColor,
        onPressed: onRepost,
        effect: EngagementEffect.spin,
        playOnTap: true,
      ),
      _EngagementMetric(
        layout: layout,
        onMedia: onMedia,
        icon: post.engagement.viewer.isSaved
            ? Icons.bookmark
            : Icons.bookmark_border,
        label: AppStrings.postSaves,
        count: post.engagement.saveCount,
        color: saveColor,
        onPressed: onSave,
        effect: EngagementEffect.bounce,
        isActive: post.engagement.viewer.isSaved,
      ),
    ];

    if (layout == PostEngagementLayout.vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final metric in metrics) ...[
            metric,
            if (metric != metrics.last)
              const SizedBox(height: UIConstants.fullscreenEngagementSpacing),
          ],
        ],
      );
    }

    return Row(
      children: [for (final metric in metrics) Expanded(child: metric)],
    );
  }
}

class _EngagementMetric extends StatelessWidget {
  const _EngagementMetric({
    required this.layout,
    required this.onMedia,
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.onPressed,
    required this.effect,
    this.isActive = false,
    this.playOnTap = false,
  });

  final PostEngagementLayout layout;
  final bool onMedia;
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  final EngagementEffect effect;
  final bool isActive;
  final bool playOnTap;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final mediaTheme = MediaOverlayTheme.of(context);
    final accessibleLabel = '$label: $count';
    final iconSize = layout == PostEngagementLayout.vertical
        ? UIConstants.fullscreenEngagementIconSize
        : UIConstants.postEngagementIconSize;
    final countStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
      color: onMedia ? mediaTheme.foregroundColor : color,
      fontWeight: FontWeight.w600,
      shadows: onMedia ? UIConstants.postMediaTextShadows : null,
    );

    return Semantics(
      label: accessibleLabel,
      container: true,
      button: true,
      enabled: onPressed != null,
      onTap: onPressed,
      excludeSemantics: true,
      child: layout == PostEngagementLayout.vertical
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildButton(accessibleLabel, iconSize),
                const SizedBox(height: UIConstants.postEngagementItemSpacing),
                AnimatedSwitcher(
                  duration: UIConstants.engagementColorDuration,
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween(
                        begin: const Offset(0, 0.6),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  ),
                  child: Text(
                    '$count',
                    key: ValueKey(count),
                    style: countStyle,
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildButton(accessibleLabel, iconSize),
                const SizedBox(width: UIConstants.postEngagementItemSpacing),
                Flexible(
                  child: Text(
                    '$count',
                    overflow: TextOverflow.ellipsis,
                    style: countStyle,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildButton(String accessibleLabel, double iconSize) =>
      AnimatedEngagementIcon(
        icon: icon,
        color: color,
        iconSize: iconSize,
        buttonSize: UIConstants.postEngagementButtonSize,
        tooltip: accessibleLabel,
        effect: effect,
        isActive: isActive,
        playOnTap: playOnTap,
        onPressed: onPressed,
      );
}
