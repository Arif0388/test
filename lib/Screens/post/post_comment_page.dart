import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/post/post_comment_item.dart';
import 'package:learningx_flutter_app/api/model/comment_model.dart';
import 'package:learningx_flutter_app/api/provider/post_comment_provider.dart';

class CommentActivity extends ConsumerStatefulWidget {
  final String id;
  const CommentActivity({super.key, required this.id});

  @override
  ConsumerState<CommentActivity> createState() => _CommentActivityState();
}

class _CommentActivityState extends ConsumerState<CommentActivity> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController commentController = TextEditingController();

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
      ref.read(postCommentProvider(widget.id).notifier).fetchComments();
    }
  }

  void nextBtnClicked() async {
    if (commentController.text.isNotEmpty) {
      Map<String, dynamic> data = HashMap();
      data['comment'] = commentController.text;
      data['post'] = widget.id;
      await ref
          .read(postCommentProvider(widget.id).notifier)
          .createPostCommentApi(context, data);
      commentController.text = "";
    }
  }

  void deleteComment(String commentId) async {
    Map<String, dynamic> data = HashMap();
    data['_id'] = commentId;
    data['post'] = widget.id;
    await ref
        .read(postCommentProvider(widget.id).notifier)
        .deletePostCommentApi(context, data);
  }

  @override
  Widget build(BuildContext context) {
    final comments = ref.watch(postCommentProvider(widget.id));
    final isLoading = ref.watch(postCommentProvider(widget.id)
        .notifier
        .select((state) => state.isLoading));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Center(
                child: RefreshIndicator(
              onRefresh: () async {
                // Handle refresh logic here
              },
              child: isLoading
                  ? const CircularProgressIndicator()
                  : comments.isEmpty
                      ? const Text('No comments available')
                      : ListView.builder(
                          key: const PageStorageKey<String>('postCommentList'),
                          controller: _scrollController,
                          itemCount: comments.length + (isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == comments.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              );
                            }
                            PostComment comment = comments[index];
                            return CommentItemWidget(
                                comment: comment,
                                onDeleteComment: deleteComment);
                          },
                        ),
            )),
          ),
        ],
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: commentController,
                minLines: 1,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'comment here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                nextBtnClicked();
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
