import 'package:material_ui/material_ui.dart';

import '../../../model/party/user_profile.dart';
import '../../../model/post/post.dart';
import '../../../util/const/ui/ui_constants.dart';
import 'post_author_header.dart';

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
    final titleStyle = textTheme.titleMedium?.copyWith(
      color: Colors.white,
      shadows: UIConstants.postMediaTextShadows,
    );
    final contentStyle = textTheme.bodyMedium?.copyWith(
      color: Colors.white,
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
          Text(
            content,
            maxLines: UIConstants.postMediaCaptionMaxLines,
            overflow: TextOverflow.ellipsis,
            style: contentStyle,
          ),
        ],
      ],
    );
  }
}
