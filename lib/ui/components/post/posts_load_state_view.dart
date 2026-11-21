import 'package:material_ui/material_ui.dart';

import '../../../provider/post/posts_provider.dart';
import '../../../util/const/app/app_strings.dart';

/// Widget reutilizável que representa os estados de carregamento do feed de
/// posts (loading, erro e vazio). Use-o em todos os feeds/páginas que exibem
/// [PostsProvider] para garantir consistência visual e evitar duplicação.
///
/// [status] e [hasPosts] determinam qual estado é exibido:
/// - **loading / initial** sem posts → indicador circular.
/// - **error** sem posts → mensagem + botão de retry.
/// - **loaded** sem posts → [emptyChild] (ou mensagem padrão).
/// - Com posts → [loadedChild].
class PostsLoadStateView extends StatelessWidget {
  const PostsLoadStateView({
    required this.status,
    required this.hasPosts,
    required this.onRetry,
    required this.loadedChild,
    this.emptyChild,
    this.loadingIndicatorColor,
    super.key,
  });

  final PostsLoadStatus status;
  final bool hasPosts;
  final VoidCallback onRetry;
  final Widget loadedChild;
  final Widget? emptyChild;

  /// Cor opcional do [CircularProgressIndicator] (ex.: branco em fundos escuros).
  final Color? loadingIndicatorColor;

  @override
  Widget build(BuildContext context) {
    if (!hasPosts) {
      if (status == PostsLoadStatus.initial ||
          status == PostsLoadStatus.loading) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: CircularProgressIndicator(color: loadingIndicatorColor),
          ),
        );
      }

      if (status == PostsLoadStatus.error) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.postsLoadFailed,
                  style: loadingIndicatorColor != null
                      ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: loadingIndicatorColor,
                          )
                      : null,
                ),
                TextButton(
                  onPressed: onRetry,
                  child: const Text(AppStrings.retry),
                ),
              ],
            ),
          ),
        );
      }

      return SliverFillRemaining(
        hasScrollBody: false,
        child: emptyChild ??
            const Center(child: Text(AppStrings.noPostsAvailable)),
      );
    }

    return loadedChild;
  }
}
