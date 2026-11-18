import 'package:material_ui/material_ui.dart';

import '../../../model/post/post.dart';
import '../../../util/const/app/app_strings.dart';
import '../../../util/const/ui/ui_constants.dart';

class PostEngagementBar extends StatelessWidget {
  const PostEngagementBar({required this.post, super.key});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inactiveColor = theme.colorScheme.onSurfaceVariant;
    final likeColor = post.engagement.viewer.isReacted
        ? theme.colorScheme.primary
        : inactiveColor;
    final saveColor = post.engagement.viewer.isSaved
        ? theme.colorScheme.primary
        : inactiveColor;

    return Row(
      children: [
        Expanded(
          child: _EngagementMetric(
            icon: Icons.mode_comment_outlined,
            label: AppStrings.postComments,
            count: post.engagement.commentCount,
            color: inactiveColor,
          ),
        ),
        Expanded(
          child: _EngagementMetric(
            icon: post.engagement.viewer.isReacted
                ? Icons.favorite
                : Icons.favorite_border,
            label: AppStrings.postLikes,
            count: post.engagement.reactionCount,
            color: likeColor,
          ),
        ),
        Expanded(
          child: _EngagementMetric(
            icon: Icons.repeat,
            label: AppStrings.postReposts,
            count: post.engagement.shareCount,
            color: inactiveColor,
          ),
        ),
        Expanded(
          child: _EngagementMetric(
            icon: post.engagement.viewer.isSaved
                ? Icons.bookmark
                : Icons.bookmark_border,
            label: AppStrings.postSaves,
            count: post.engagement.saveCount,
            color: saveColor,
          ),
        ),
      ],
    );
  }
}

class _EngagementMetric extends StatelessWidget {
  const _EngagementMetric({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final accessibleLabel = '$label: $count';
    return Semantics(
      label: accessibleLabel,
      container: true,
      excludeSemantics: true,
      child: Tooltip(
        message: accessibleLabel,
        excludeFromSemantics: true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: UIConstants.postEngagementIconSize, color: color),
            const SizedBox(width: UIConstants.postEngagementItemSpacing),
            Flexible(
              child: Text(
                '$count',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium
                    ?.copyWith(color: color, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
