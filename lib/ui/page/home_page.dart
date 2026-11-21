import 'dart:async';

import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../provider/bottom_navigation_bar/bottom_navigation_provider.dart';
import '../../provider/post/posts_provider.dart';
import '../../util/const/app/app_strings.dart';
import '../../util/const/app/feed_constants.dart';
import '../../util/const/ui/ui_constants.dart';
import '../components/app_bar/app_bar.dart';
import '../components/post/post_card.dart';
import '../components/post/posts_load_state_view.dart';
import '../components/screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<PostsProvider, (List, PostsLoadStatus)>(
      selector: (_, p) => (p.feedPosts, p.status),
      builder: (context, _, _) {
        final provider = context.read<PostsProvider>();
        final posts = provider.feedPosts;

        return NotificationListener<Notification>(
          onNotification: (notification) =>
              _handleScrollNotification(context, provider, notification),
          child: Screen(
            appBar: const CustomAppBar(floating: true, snap: true),
            onRefresh: () => _refresh(context, provider),
            slivers: [
              PostsLoadStateView(
                status: provider.status,
                hasPosts: posts.isNotEmpty,
                onRetry: provider.load,
                loadedChild: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index.isOdd) {
                        final postIndex = index ~/ 2;
                        if (postIndex < posts.length - 1) {
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
                        return _FeedFooter(provider: provider);
                      }

                      final postIndex = index ~/ 2;
                      final post = posts[postIndex];
                      return PostCard(
                        post: post,
                        author: provider.authorFor(post),
                      );
                    },
                    childCount: posts.length * 2,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Trata as duas responsabilidades do scroll em um único método extraído:
  /// 1. compactação da barra de navegação ao rolar para baixo;
  /// 2. carregamento de mais posts ao se aproximar do fim da lista.
  bool _handleScrollNotification(
    BuildContext context,
    PostsProvider provider,
    Notification notification,
  ) {
    if (notification is UserScrollNotification &&
        notification.metrics.axis == Axis.vertical) {
      final isCompact = switch (notification.direction) {
        ScrollDirection.reverse => true,
        ScrollDirection.forward => false,
        ScrollDirection.idle => null,
      };
      if (isCompact != null) {
        context.read<BottomNavigationProvider>().setCompact(isCompact);
      }
    }

    final metrics = switch (notification) {
      ScrollNotification(:final metrics) => metrics,
      ScrollMetricsNotification(:final metrics) => metrics,
      _ => null,
    };
    if (metrics != null &&
        metrics.axis == Axis.vertical &&
        metrics.extentAfter < FeedConstants.loadMoreExtent) {
      unawaited(provider.loadMore());
    }
    return false;
  }

  Future<void> _refresh(BuildContext context, PostsProvider provider) async {
    await provider.load(refresh: true);
    if (!context.mounted || provider.error == null) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text(AppStrings.postsLoadFailed)));
  }
}

class _FeedFooter extends StatelessWidget {
  const _FeedFooter({required this.provider});

  final PostsProvider provider;

  @override
  Widget build(BuildContext context) {
    final bottomPadding =
        UIConstants.bottomNavigationHeight +
        UIConstants.bottomNavigationOuterPadding +
        UIConstants.bottomNavigationBottomPadding +
        UIConstants.spaceLg;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        UIConstants.postCardContentPadding,
        UIConstants.postArticleSectionSpacing,
        UIConstants.postCardContentPadding,
        bottomPadding,
      ),
      child: Center(
        child: switch ((
          provider.isLoadingMore,
          provider.loadMoreError,
          provider.hasMore,
        )) {
          (true, _, _) => const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: UIConstants.postCardSpacing),
              Text(AppStrings.loadingMorePosts),
            ],
          ),
          (false, Object _, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(AppStrings.postsLoadFailed),
              TextButton(
                onPressed: provider.loadMore,
                child: const Text(AppStrings.retry),
              ),
            ],
          ),
          (false, null, false) => Text(
            AppStrings.postsEndReached,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          _ => const SizedBox(height: UIConstants.postCardSpacing),
        },
      ),
    );
  }
}
