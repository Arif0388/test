import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/post/post_item.dart';
import 'package:learningx_flutter_app/api/model/post_model.dart';
import 'package:learningx_flutter_app/api/provider/post_provider.dart';

class PostFragmentPage extends ConsumerStatefulWidget {
  final String query;
  final Widget page;
  const PostFragmentPage({super.key, required this.query, required this.page});

  @override
  ConsumerState<PostFragmentPage> createState() => _PostFragmentPageState();
}

class _PostFragmentPageState extends ConsumerState<PostFragmentPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(postProvider(widget.query).notifier).fetchPosts();
    }
  }

  Future<void> _refresh() async {
    ref.read(postProvider(widget.query).notifier).refreshPosts();
  }

  void handleDeletePost(String postId) {
    ref.read(postProvider(widget.query).notifier).deletePost(postId);
  }

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(postProvider(widget.query));
    final isLoading = ref.watch(
        postProvider(widget.query).notifier.select((state) => state.isLoading));

    return Scaffold(
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : posts.isEmpty
                ? Column(children: [
                    widget.page,
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'No posts available',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ])
                : ListView.builder(
                    key: const PageStorageKey<String>('postList'),
                    controller: _scrollController,
                    itemCount: posts.length + 1 + (isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == posts.length + 1) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (index == 0) {
                        return widget.page;
                      } else {
                        Post post = posts[index - 1];
                        return PostItemWidget(
                          totalPosts: posts,
                          post: post,
                          onDeletePost: handleDeletePost,
                        );
                      }
                    },
                  ),
      ),
    );
  }
}
