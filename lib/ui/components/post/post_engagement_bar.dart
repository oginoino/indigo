import 'package:material_ui/material_ui.dart';

import '../../../model/post/post.dart';
import '../../../util/const/app/app_strings.dart';
import '../../../util/const/ui/ui_constants.dart';

enum PostEngagementLayout { horizontal, vertical }

class PostEngagementBar extends StatelessWidget {
  const PostEngagementBar({
    required this.post,
    this.layout = PostEngagementLayout.horizontal,
    this.onMedia = false,
    super.key,
  });

  final Post post;
  final PostEngagementLayout layout;
  final bool onMedia;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inactiveColor = onMedia
        ? Colors.white
        : theme.colorScheme.onSurfaceVariant;
    final likeColor = post.engagement.viewer.isReacted
        ? onMedia
              ? UIConstants.fullscreenLikedColor
              : theme.colorScheme.primary
        : inactiveColor;
    final saveColor = post.engagement.viewer.isSaved
        ? onMedia
              ? Colors.white
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
      ),
      _EngagementMetric(
        layout: layout,
        onMedia: onMedia,
        icon: Icons.repeat,
        label: AppStrings.postReposts,
        count: post.engagement.shareCount,
        color: inactiveColor,
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
  });

  final PostEngagementLayout layout;
  final bool onMedia;
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final accessibleLabel = '$label: $count';
    final iconSize = layout == PostEngagementLayout.vertical
        ? UIConstants.fullscreenEngagementIconSize
        : UIConstants.postEngagementIconSize;
    final countStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
      color: onMedia ? Colors.white : color,
      fontWeight: FontWeight.w600,
      shadows: onMedia ? UIConstants.postMediaTextShadows : null,
    );

    return Semantics(
      label: accessibleLabel,
      container: true,
      excludeSemantics: true,
      child: Tooltip(
        message: accessibleLabel,
        excludeFromSemantics: true,
        child: layout == PostEngagementLayout.vertical
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: iconSize, color: color),
                  const SizedBox(height: UIConstants.postEngagementItemSpacing),
                  Text('$count', style: countStyle),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: iconSize, color: color),
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
      ),
    );
  }
}
