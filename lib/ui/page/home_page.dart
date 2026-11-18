import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../provider/post/posts_provider.dart';
import '../../util/const/app/app_strings.dart';
import '../components/app_bar/app_bar.dart';
import '../components/post/post_card.dart';
import '../components/screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Screen(
      appBar: const CustomAppBar(),
      child: Consumer<PostsProvider>(
        builder: (context, provider, _) {
          if (provider.status == PostsLoadStatus.loading ||
              provider.status == PostsLoadStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.status == PostsLoadStatus.error) {
            return Center(
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
            );
          }

          final posts = provider.feedPosts;
          if (posts.isEmpty) {
            return const Center(child: Text(AppStrings.noPostsAvailable));
          }

          return RefreshIndicator(
            onRefresh: () => provider.load(refresh: true),
            child: ListView.builder(
              primary: false,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: posts.length,
              itemBuilder: (context, index) => PostCard(post: posts[index]),
            ),
          );
        },
      ),
    );
  }
}
