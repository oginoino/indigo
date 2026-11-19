import 'package:material_ui/material_ui.dart';

import '../../../util/const/app/app_strings.dart';
import '../../../util/const/ui/ui_constants.dart';

class PostMediaLoadError extends StatelessWidget {
  const PostMediaLoadError({
    required this.message,
    required this.onRetry,
    required this.icon,
    this.onDarkBackground = false,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;
  final IconData icon;
  final bool onDarkBackground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foregroundColor = onDarkBackground
        ? Colors.white
        : theme.colorScheme.onSurface;
    final secondaryColor = onDarkBackground
        ? Colors.white70
        : theme.colorScheme.onSurfaceVariant;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxHeight < 180 || constraints.maxWidth < 180;
        return Semantics(
          liveRegion: true,
          label: message,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(UIConstants.spaceXs),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: compact
                        ? UIConstants.postEngagementIconSize
                        : UIConstants.postMediaErrorIconSize,
                    color: secondaryColor,
                  ),
                  if (!compact) ...[
                    const SizedBox(height: UIConstants.spaceXs),
                    Text(
                      message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: secondaryColor,
                      ),
                    ),
                  ],
                  IconButton(
                    tooltip: AppStrings.retry,
                    onPressed: onRetry,
                    color: foregroundColor,
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
