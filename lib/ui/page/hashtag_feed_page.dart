import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../model/hashtag.dart';
import '../../provider/feed/feeds_list_provider.dart';
import '../../provider/post/posts_provider.dart';
import '../../util/const/app/app_strings.dart';
import '../../util/const/app/feed_constants.dart';
import '../../util/const/ui/ui_constants.dart';
import '../components/app_bar/app_bar.dart';
import '../components/post/post_card.dart';
import '../components/post/posts_load_state_view.dart';
import '../components/screen.dart';

class HashtagFeedPage extends StatelessWidget {
  const HashtagFeedPage({required this.hashtagId, super.key});

  final String hashtagId;

  @override
  Widget build(BuildContext context) {
    final hashtag = context.read<FeedsListProvider>().hashtagById(hashtagId);
    if (hashtag == null) {
      return const Scaffold(
        body: SafeArea(child: Center(child: Text(AppStrings.noPostsAvailable))),
      );
    }

    return PopScope<void>(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          context.read<FeedsListProvider>().leaveHashtagFeed(hashtagId);
        }
      },
      child: Consumer<PostsProvider>(
        builder: (context, provider, _) {
          final posts = provider.postsForHashtag(hashtagId);

          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.extentAfter <
                  FeedConstants.loadMoreExtent) {
                unawaited(provider.loadMore());
              }
              return false;
            },
            child: Screen(
              appBar: const CustomAppBar(floating: true, snap: true),
              onRefresh: () => provider.load(refresh: true),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: UIConstants.postCardHorizontalInset,
                      vertical: UIConstants.postCardOuterSpacing,
                    ),
                    child: _HashtagHeader(hashtag: hashtag),
                  ),
                ),
                PostsLoadStateView(
                  status: provider.status,
                  hasPosts: posts.isNotEmpty,
                  onRetry: provider.load,
                  emptyChild: Center(
                    child: provider.hasMore
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(AppStrings.noHashtagPosts),
                              TextButton(
                                onPressed: provider.loadMore,
                                child: const Text(AppStrings.loadMorePosts),
                              ),
                            ],
                          )
                        : const Text(AppStrings.noHashtagPosts),
                  ),
                  loadedChild: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == posts.length) {
                          return Padding(
                            padding: const EdgeInsets.all(UIConstants.spaceLg),
                            child: Center(
                              child: provider.isLoadingMore
                                  ? const CircularProgressIndicator()
                                  : provider.loadMoreError != null
                                  ? TextButton(
                                      onPressed: provider.loadMore,
                                      child: const Text(AppStrings.retry),
                                    )
                                  : !provider.hasMore
                                  ? const Text(AppStrings.postsEndReached)
                                  : const SizedBox.shrink(),
                            ),
                          );
                        }

                        final post = posts[index];
                        return PostCard(
                          post: post,
                          author: provider.authorFor(post),
                        );
                      },
                      childCount: posts.length + 1,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HashtagHeader extends StatelessWidget {
  const _HashtagHeader({required this.hashtag});

  final Hashtag hashtag;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = switch (hashtag.type) {
      HashtagType.user => colorScheme.primary,
      HashtagType.official => colorScheme.tertiary,
      HashtagType.community => colorScheme.secondary,
    };
    final icon = switch (hashtag.type) {
      HashtagType.user => Icons.tag,
      HashtagType.official => Icons.verified_outlined,
      HashtagType.community => Icons.groups_outlined,
    };

    return Row(
      spacing: UIConstants.spaceSm,
      children: [
        Expanded(
          child: Text(
            hashtag.displayLabel,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ),
        Icon(icon, color: color),
      ],
    );
  }
}
