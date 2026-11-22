import 'package:material_ui/material_ui.dart';

import '../../../provider/post/posts_provider.dart';
import '../../../util/const/app/app_strings.dart';
import '../../../util/const/ui/ui_constants.dart';

/// Widget reutilizável que representa os estados de carregamento do feed de
/// posts (loading, erro e vazio). Use-o em todos os feeds/páginas que exibem
/// [PostsProvider] para garantir consistência visual e evitar duplicação.
///
/// [status] e [hasPosts] determinam qual estado é exibido:
/// - **loading / initial** sem posts → skeleton animado com 4 cards fantasma.
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

  /// Cor opcional do indicador de loading (ex.: branco em fundos escuros).
  final Color? loadingIndicatorColor;

  @override
  Widget build(BuildContext context) {
    if (!hasPosts) {
      if (status == PostsLoadStatus.initial ||
          status == PostsLoadStatus.loading) {
        return _PostFeedSkeleton(shimmerColor: loadingIndicatorColor);
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

// ---------------------------------------------------------------------------
// Skeleton: lista de cards fantasma com shimmer nativo (sem package externo)
// ---------------------------------------------------------------------------

/// Número de cards skeleton exibidos durante o carregamento inicial.
const int _kSkeletonCardCount = 4;

/// Lista de cards skeleton com animação de shimmer — substitui a tela escura
/// enquanto o feed ainda não carregou nenhum post.
class _PostFeedSkeleton extends StatelessWidget {
  const _PostFeedSkeleton({this.shimmerColor});

  final Color? shimmerColor;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index.isOdd) {
            // Divisor entre cards skeleton.
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.postCardHorizontalInset,
              ),
              child: const Divider(
                height: UIConstants.postFeedDividerHeight,
                thickness: UIConstants.postFeedDividerThickness,
              ),
            );
          }
          return _PostCardSkeleton(shimmerColor: shimmerColor);
        },
        childCount: _kSkeletonCardCount * 2,
      ),
    );
  }
}

/// Card fantasma de um post com animação de shimmer pulse.
///
/// Implementa shimmer puramente com [AnimationController] + [AnimatedBuilder]
/// — sem dependência de package externo.
class _PostCardSkeleton extends StatefulWidget {
  const _PostCardSkeleton({this.shimmerColor});

  final Color? shimmerColor;

  @override
  State<_PostCardSkeleton> createState() => _PostCardSkeletonState();
}

class _PostCardSkeletonState extends State<_PostCardSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: UIConstants.skeletonShimmerDuration,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final baseColor = widget.shimmerColor?.withValues(alpha: 0.08) ??
        colors.onSurface.withValues(alpha: 0.08);
    final highlightColor = widget.shimmerColor?.withValues(alpha: 0.16) ??
        colors.onSurface.withValues(alpha: 0.16);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final shimmerColor =
            Color.lerp(baseColor, highlightColor, _animation.value)!;
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.postCardHorizontalInset,
            vertical: UIConstants.spaceSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: avatar + nome + tempo
              Row(
                children: [
                  _ShimmerBox(
                    width: UIConstants.skeletonAvatarSize,
                    height: UIConstants.skeletonAvatarSize,
                    borderRadius: UIConstants.skeletonAvatarSize / 2,
                    color: shimmerColor,
                  ),
                  const SizedBox(width: UIConstants.spaceSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ShimmerBox(
                          width: UIConstants.skeletonNameWidth,
                          height: UIConstants.skeletonLineHeight,
                          color: shimmerColor,
                        ),
                        const SizedBox(height: UIConstants.spaceXs),
                        _ShimmerBox(
                          width: UIConstants.skeletonMetaWidth,
                          height: UIConstants.skeletonLineHeightSm,
                          color: shimmerColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: UIConstants.spaceMd),
              // Corpo: 3 linhas de texto
              _ShimmerBox(
                width: double.infinity,
                height: UIConstants.skeletonLineHeight,
                color: shimmerColor,
              ),
              const SizedBox(height: UIConstants.spaceXs),
              _ShimmerBox(
                width: double.infinity,
                height: UIConstants.skeletonLineHeight,
                color: shimmerColor,
              ),
              const SizedBox(height: UIConstants.spaceXs),
              _ShimmerBox(
                width: UIConstants.skeletonLastLineWidth,
                height: UIConstants.skeletonLineHeight,
                color: shimmerColor,
              ),
              const SizedBox(height: UIConstants.spaceMd),
              // Mídia placeholder
              _ShimmerBox(
                width: double.infinity,
                height: UIConstants.skeletonMediaHeight,
                borderRadius: UIConstants.postCardRadius,
                color: shimmerColor,
              ),
              const SizedBox(height: UIConstants.spaceMd),
              // Rodapé: ações de engajamento
              Row(
                children: [
                  _ShimmerBox(
                    width: UIConstants.skeletonActionWidth,
                    height: UIConstants.skeletonLineHeightSm,
                    color: shimmerColor,
                  ),
                  const SizedBox(width: UIConstants.spaceLg),
                  _ShimmerBox(
                    width: UIConstants.skeletonActionWidth,
                    height: UIConstants.skeletonLineHeightSm,
                    color: shimmerColor,
                  ),
                  const SizedBox(width: UIConstants.spaceLg),
                  _ShimmerBox(
                    width: UIConstants.skeletonActionWidth,
                    height: UIConstants.skeletonLineHeightSm,
                    color: shimmerColor,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Bloco shimmer genérico com bordas arredondadas.
class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.color,
    this.borderRadius = UIConstants.skeletonBoxRadius,
  });

  final double width;
  final double height;
  final Color color;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: SizedBox(width: width, height: height),
    );
  }
}
