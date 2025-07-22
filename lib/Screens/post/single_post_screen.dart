import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/post/post_item.dart';
import 'package:learningx_flutter_app/api/model/post_model.dart';
import 'package:learningx_flutter_app/api/provider/post_provider.dart';

class SinglePostScreen extends ConsumerStatefulWidget {
  final String id;
  const SinglePostScreen({super.key, required this.id});

  @override
  ConsumerState<SinglePostScreen> createState() => _SinglePostScreenState();
}

class _SinglePostScreenState extends ConsumerState<SinglePostScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void handleDeletePost(String postId) {
    ref.read(postProvider("_id=${widget.id}").notifier).deletePost(postId);
  }

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(postProvider("_id=${widget.id}"));
    final isLoading = ref.watch(
        postProvider(widget.id).notifier.select((state) => state.isLoading));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Post"),
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : posts.isEmpty
                ? const Text('No posts available')
                : ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      Post post = posts[index];
                      return PostItemWidget(
                        totalPosts: posts,
                        post: post,
                        onDeletePost: handleDeletePost,
                      );
                    },
                  ),
      ),
    );
  }
}
