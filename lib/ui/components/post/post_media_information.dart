import 'package:material_ui/material_ui.dart';

import '../../../model/party/user_profile.dart';
import '../../../model/post/post.dart';
import '../../../util/const/app/post_constants.dart';
import '../../../util/const/ui/ui_constants.dart';
import '../../theme/media_overlay_theme.dart';
import 'post_author_header.dart';
import 'post_content_text.dart';

class PostMediaInformation extends StatelessWidget {
  const PostMediaInformation({
    required this.post,
    required this.author,
    super.key,
  });

  final Post post;
  final UserProfile? author;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final mediaTheme = MediaOverlayTheme.of(context);
    final titleStyle = textTheme.titleMedium?.copyWith(
      color: mediaTheme.foregroundColor,
      shadows: UIConstants.postMediaTextShadows,
    );
    final contentStyle = textTheme.bodyMedium?.copyWith(
      color: mediaTheme.foregroundColor,
      shadows: UIConstants.postMediaTextShadows,
    );
    final content = post.content.plainText;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PostAuthorHeader(
          author: author,
          publishedAt: post.createdAt,
          location: post.location,
          onMedia: true,
        ),
        if (post.title case final title?) ...[
          const SizedBox(height: UIConstants.postHeaderSpacing),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: titleStyle,
          ),
        ],
        if (content.isNotEmpty) ...[
          const SizedBox(height: UIConstants.postHeaderTextSpacing),
          PostContentText(
            content: post.content,
            maxLines: PostConstants.fullscreenCaptionMaxLines,
            overflow: TextOverflow.ellipsis,
            style: contentStyle,
          ),
        ],
      ],
    );
  }
}
