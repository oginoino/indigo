import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:provider/provider.dart';

import '../../provider/bottom_navigation_bar/bottom_navigation_provider.dart';
import '../../provider/post/posts_provider.dart';
import '../../util/const/app/app_strings.dart';
import '../../util/const/app/feed_constants.dart';
import '../../util/const/ui/ui_constants.dart';
import '../components/app_bar/app_bar.dart';
import '../components/post/post_card.dart';
import '../components/screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PostsProvider>(
      builder: (context, provider, _) {
        final posts = provider.feedPosts;

        return NotificationListener<Notification>(
          onNotification: (notification) {
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
          },
          child: Screen(
            appBar: const CustomAppBar(floating: true, snap: true),
            onRefresh: () => _refresh(context, provider),
            slivers: [
              if ((provider.status == PostsLoadStatus.initial ||
                      provider.status == PostsLoadStatus.loading) &&
                  posts.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (provider.status == PostsLoadStatus.error &&
                  posts.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(AppStrings.postsLoadFailed),
                        TextButton(
                          onPressed: provider.load,
                          child: const Text(AppStrings.retry),
                        ),
                      ],
                    ),
                  ),
                )
              else if (posts.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text(AppStrings.noPostsAvailable)),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
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
                  }, childCount: posts.length * 2),
                ),
            ],
          ),
        );
      },
    );
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
