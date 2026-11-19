import 'package:material_ui/material_ui.dart';

import '../../model/party/user_profile.dart';
import '../../model/post/post.dart';
import '../../util/const/app/app_strings.dart';
import '../../util/const/ui/ui_constants.dart';
import '../components/post/post_author_header.dart';
import '../components/post/post_engagement_bar.dart';
import '../components/post/post_media_gallery.dart';
import '../components/post/post_content_text.dart';

class PostArticlePage extends StatelessWidget {
  const PostArticlePage({required this.post, required this.author, super.key});

  final Post post;
  final UserProfile? author;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = post.title?.trim();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.postArticleTitle)),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: UIConstants.postArticleMaxWidth,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.postArticleHorizontalPadding,
                  vertical: UIConstants.postArticleSectionSpacing,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PostAuthorHeader(
                      author: author,
                      publishedAt: post.createdAt,
                    ),
                    if (title != null && title.isNotEmpty) ...[
                      const SizedBox(
                        height: UIConstants.postArticleSectionSpacing,
                      ),
                      Text(title, style: theme.textTheme.headlineSmall),
                    ],
                    const SizedBox(height: UIConstants.spaceLg),
                    if (post.content.plainText.trim().isNotEmpty)
                      PostContentText(
                        content: post.content,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: UIConstants.postArticleBodyLineHeight,
                        ),
                        selectable: true,
                      ),
                    if (post.media.isNotEmpty) ...[
                      const SizedBox(
                        height: UIConstants.postArticleSectionSpacing,
                      ),
                      PostMediaGallery(post: post, author: author),
                    ],
                    const SizedBox(
                      height: UIConstants.postArticleSectionSpacing,
                    ),
                    const Divider(),
                    PostEngagementBar(post: post),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
