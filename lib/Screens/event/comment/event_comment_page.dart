import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/event/comment/event_comment_item.dart';
import 'package:learningx_flutter_app/api/model/event_comment_model.dart';
import 'package:learningx_flutter_app/api/model/event_model.dart';
import 'package:learningx_flutter_app/api/provider/event_comment_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventCommentActivity extends ConsumerStatefulWidget {
  final Event event;
  const EventCommentActivity({super.key, required this.event});
  @override
  ConsumerState<EventCommentActivity> createState() => _EventCommentState();
}

class _EventCommentState extends ConsumerState<EventCommentActivity> {
  final TextEditingController commentController = TextEditingController();

  // Move data outside of the build method to avoid re-creating it every time
  late final Map<String, String> map;
  var isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    // Initialize the data map only once in initState
    map = {'parentCommentId': "null", 'eventId': widget.event.id};
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      var currentUserId = prefs.getString("id") ?? "";
      isAdmin = widget.event.admin.any((item) => item.id == currentUserId);
    });
  }

  void deleteComment(String commentId) async {
    Map<String, dynamic> data = HashMap();
    data['_id'] = commentId;
    data['event'] = widget.event.id;
    await ref
        .read(eventCommentProvider(map).notifier)
        .deleteEventCommentApi(context, data);
  }

  void nextBtnClicked() async {
    if (commentController.text.isNotEmpty) {
      Map<String, dynamic> data = HashMap();
      data['comment'] = commentController.text;
      data['event'] = widget.event.id;
      await ref
          .read(eventCommentProvider(map).notifier)
          .createEventComment(context, data);
      // Clear the comment input
      commentController.clear();

      // Optionally, refresh the comments to reflect the new reply
      ref.refresh(eventCommentProvider(map));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Now data is initialized once and reused
    final comments = ref.watch(eventCommentProvider(map));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.eventTitle),
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Divider(height: 1, color: Colors.grey[300]),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                // Handle refresh logic here
              },
              child: ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  EventComment comment = comments[index];
                  return EventCommentItem(
                    comment: comment,
                    isAdmin: isAdmin,
                    isRepliedComment: false,
                    onDeleteComment: deleteComment,
                  );
                },
              ),
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
