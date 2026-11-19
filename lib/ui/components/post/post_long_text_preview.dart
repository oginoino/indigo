import 'package:material_ui/material_ui.dart';

import '../../../model/party/user_profile.dart';
import '../../../model/post/post.dart';
import '../../../util/const/app/app_strings.dart';
import '../../../util/const/ui/ui_constants.dart';
import '../../page/post_article_page.dart';

class PostLongTextPreview extends StatelessWidget {
  const PostLongTextPreview({
    required this.post,
    required this.author,
    required this.text,
    super.key,
  });

  final Post post;
  final UserProfile? author;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth) {
          return Text(text, style: theme.textTheme.bodyLarge);
        }

        final textPainter = TextPainter(
          text: TextSpan(text: text, style: theme.textTheme.bodyLarge),
          maxLines: UIConstants.postPreviewMaxLines,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: constraints.maxWidth);
        final hasMore = textPainter.didExceedMaxLines;
        textPainter.dispose();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              maxLines: hasMore ? UIConstants.postPreviewMaxLines : null,
              overflow: hasMore ? TextOverflow.ellipsis : TextOverflow.clip,
              style: theme.textTheme.bodyLarge,
            ),
            if (hasMore)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          PostArticlePage(post: post, author: author),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text(AppStrings.postReadMore),
                ),
              ),
          ],
        );
      },
    );
  }
}
