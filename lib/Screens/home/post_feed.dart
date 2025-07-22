import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/post/post_form.dart';
import 'package:learningx_flutter_app/Screens/post/post_item.dart';
import 'package:learningx_flutter_app/api/model/post_model.dart';
import 'package:learningx_flutter_app/api/provider/post_feed_provider.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(postFeedProvider.notifier).fetchPosts();
    }
  }

  Future<void> _refresh() async {
    ref.read(postFeedProvider.notifier).refreshPostFeed();
  }

  void handleDeletePost(String postId) {
    ref.read(postFeedProvider.notifier).deletePost(postId);
  }

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(postFeedProvider);
    final isLoading =
        ref.watch(postFeedProvider.notifier.select((state) => state.isLoading));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Feed"),
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Center(
          child: isLoading && posts.isEmpty
              ? const CircularProgressIndicator()
              : posts.isEmpty
                  ? const Text('No posts available')
                  : ListView.builder(
                      key: const PageStorageKey<String>('feedList'),
                      controller: _scrollController,
                      itemCount: posts.length + (isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == posts.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        Post post = posts[index];
                        return PostItemWidget(
                          totalPosts: posts,
                          post: post,
                          onDeletePost: handleDeletePost,
                        );
                      },
                    ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 56, 114, 220),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const CreatePostPage(
                      toEdit: false,
                    )),
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
