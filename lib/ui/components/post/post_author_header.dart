import 'package:material_ui/material_ui.dart';

import '../../../model/party/user_profile.dart';
import '../../../model/post/post_location.dart';
import '../../../util/const/app/app_strings.dart';
import '../../../util/const/ui/ui_constants.dart';
import '../../../util/formatter/post_time_formatter.dart';
import '../../theme/media_overlay_theme.dart';
import '../avatar.dart';

class PostAuthorHeader extends StatelessWidget {
  const PostAuthorHeader({
    required this.author,
    required this.publishedAt,
    this.location,
    this.onMedia = false,
    super.key,
  });

  final UserProfile? author;
  final DateTime publishedAt;
  final PostLocation? location;
  final bool onMedia;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaTheme = MediaOverlayTheme.of(context);
    final absoluteTime = PostTimeFormatter.formatAbsolute(publishedAt);
    final titleColor = onMedia ? mediaTheme.foregroundColor : null;
    final detailColor = onMedia ? mediaTheme.secondaryForegroundColor : null;
    final semanticLabel = AppStrings.postPublishedOn.replaceAll(
      '{date}',
      absoluteTime,
    );
    final locationName = location?.name.trim();
    final avatarUrl = author?.avatarUrl;

    return Row(
      children: [
        Avatar(
          diameter: UIConstants.postHeaderAvatarSize,
          imageProvider: avatarUrl == null || avatarUrl.isEmpty
              ? null
              : NetworkImage(avatarUrl),
          useSavedImage: false,
          decoration: onMedia
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: mediaTheme.foregroundColor,
                    width: UIConstants.postMediaBorderWidth,
                  ),
                )
              : null,
        ),
        const SizedBox(width: UIConstants.postHeaderSpacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                author?.displayName ?? AppStrings.unknownPostAuthor,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: titleColor,
                  shadows: onMedia ? UIConstants.postMediaTextShadows : null,
                ),
              ),
              const SizedBox(height: UIConstants.postHeaderTextSpacing),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      author == null
                          ? AppStrings.unknownUsername
                          : '@${author!.username}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: detailColor,
                        shadows: onMedia
                            ? UIConstants.postMediaTextShadows
                            : null,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: UIConstants.postHeaderTextSpacing,
                    ),
                    child: Text(
                      AppStrings.postEngagementSeparator,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: detailColor,
                        shadows: onMedia
                            ? UIConstants.postMediaTextShadows
                            : null,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Semantics(
                      label: semanticLabel,
                      child: Tooltip(
                        message: absoluteTime,
                        child: Text(
                          PostTimeFormatter.formatRelative(publishedAt),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: detailColor,
                            shadows: onMedia
                                ? UIConstants.postMediaTextShadows
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (locationName != null && locationName.isNotEmpty) ...[
                const SizedBox(height: UIConstants.postHeaderTextSpacing),
                Semantics(
                  container: true,
                  label: AppStrings.postLocation.replaceAll(
                    '{location}',
                    locationName,
                  ),
                  child: ExcludeSemantics(
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: UIConstants.postLocationIconSize,
                          color:
                              detailColor ?? theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(
                          width: UIConstants.postLocationIconSpacing,
                        ),
                        Flexible(
                          child: Tooltip(
                            message: locationName,
                            child: Text(
                              locationName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: detailColor,
                                shadows: onMedia
                                    ? UIConstants.postMediaTextShadows
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
