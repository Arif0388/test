import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/event/comment/event_comment_item.dart';
import 'package:learningx_flutter_app/api/model/event_comment_model.dart';
import 'package:learningx_flutter_app/api/provider/event_comment_provider.dart';

class EventCommentRepliesPage extends ConsumerStatefulWidget {
  final EventComment comment;
  final bool isAdmin;
  final String replyTo;
  const EventCommentRepliesPage(
      {super.key,
      required this.comment,
      required this.isAdmin,
      required this.replyTo});

  @override
  ConsumerState<EventCommentRepliesPage> createState() =>
      _EventCommentRepliesPageState();
}

class _EventCommentRepliesPageState
    extends ConsumerState<EventCommentRepliesPage> {
  final TextEditingController commentController = TextEditingController();
  final FocusNode commentFocusNode = FocusNode(); // Add a FocusNode

  // Moved data outside of the build method to avoid re-creating it every time
  late final Map<String, String> map;

  @override
  void initState() {
    super.initState();
    // Initialize the data map only once in initState
    map = {
      'eventId': widget.comment.event,
      'parentCommentId': widget.comment.id,
    };
    // Pre-fill the comment and request focus if it's a reply
    if (widget.replyTo != "") {
      commentController.text = "@${widget.replyTo} ";
      // Request focus on the TextField
      commentFocusNode.requestFocus(); // Focus the TextField
    }
  }

  @override
  void dispose() {
    commentController.dispose();
    commentFocusNode.dispose();
    super.dispose();
  }

  void deleteComment(String commentId) async {
    Map<String, dynamic> data = HashMap();
    data['_id'] = commentId;
    data['event'] = widget.comment.event;
    await ref
        .read(eventCommentProvider(map).notifier)
        .deleteEventCommentApi(context, data);
  }

  void replyComment(String displayName) async {
    commentController.text = "@$displayName ";
    commentFocusNode.requestFocus();
  }

  void nextBtnClicked() async {
    if (commentController.text.isNotEmpty) {
      Map<String, dynamic> newCommentData = HashMap();
      newCommentData['comment'] = commentController.text;
      newCommentData['event'] = widget.comment.event;
      newCommentData['parentCommentId'] = widget.comment.id;
      // Create the comment
      await ref
          .read(eventCommentProvider(map).notifier)
          .createEventComment(context, newCommentData);

      // Clear the comment input
      commentController.clear();

      // Optionally, refresh the comments to reflect the new reply
      ref.refresh(eventCommentProvider(map));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the comments for the given event and parent comment
    final comments = ref.watch(eventCommentProvider(map));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Replies"),
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Divider(height: 1, color: Colors.grey[300]),
          Expanded(
            child: ListView.builder(
              itemCount: comments.length + 1, // +1 for the original comment
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Show the original comment at the top
                  return EventCommentItem(
                    comment: widget.comment,
                    isAdmin: widget.isAdmin,
                    isRepliedComment: true,
                    onReplyComment: replyComment,
                    onDeleteComment: deleteComment,
                  );
                } else {
                  // Show the replies with left padding
                  EventComment reply = comments[index - 1];
                  return Padding(
                    padding:
                        const EdgeInsets.only(left: 16.0), // Add left padding
                    child: EventCommentItem(
                      comment: reply,
                      isAdmin: widget.isAdmin,
                      isRepliedComment: true,
                      onReplyComment: replyComment,
                      onDeleteComment: deleteComment,
                    ),
                  );
                }
              },
            ),
          ),
          Divider(height: 1, color: Colors.grey[300]),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    focusNode: commentFocusNode, // Attach the FocusNode
                    minLines: 1,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Comment here...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: nextBtnClicked,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                    child:
                        const Icon(Icons.send, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
