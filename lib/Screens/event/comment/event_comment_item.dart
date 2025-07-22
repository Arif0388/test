import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learningx_flutter_app/Screens/event/comment/event_comment_replies_page.dart';
import 'package:learningx_flutter_app/Screens/post/bottom_sheet_comment_item.dart';
import 'package:learningx_flutter_app/api/model/event_comment_model.dart';
import 'package:learningx_flutter_app/api/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventCommentItem extends StatefulWidget {
  final EventComment comment;
  final bool isAdmin;
  final bool isRepliedComment;
  final void Function(String)? onReplyComment;
  final void Function(String) onDeleteComment;
  const EventCommentItem(
      {super.key,
      required this.comment,
      required this.isAdmin,
      required this.isRepliedComment,
      this.onReplyComment,
      required this.onDeleteComment});
  @override
  State<EventCommentItem> createState() => _EventCommentItemState();
}

class _EventCommentItemState extends State<EventCommentItem> {
  String _currentUserId = "";
  bool isAdmin = false;

  @override
  void initState() {
    _loadCurrentUser();
    super.initState();
  }

  _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString("id") ?? "";
      isAdmin = widget.comment.user.id == _currentUserId || widget.isAdmin;
    });
  }

  @override
  Widget build(BuildContext context) {
    var repliedCount = 0;
    repliedCount = widget.comment.repliedCount ?? 0;

    return Container(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(width: 4.0),
              GestureDetector(
                  onTap: () {
                    context.push("/profile/${widget.comment.user.id}");
                  },
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(widget.comment.user.userImg),
                    backgroundColor: Colors.transparent,
                  )),
              const SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const SizedBox(
                          height: 32,
                        ),
                        Text(
                          widget.comment.user.displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.0,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          '- ${Utils.getTimeAgo(widget.comment.createdAtDate)}',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz),
                color: Colors.black,
                onPressed: () {
                  final BottomSheetCommentItem sheetCommentItem =
                      BottomSheetCommentItem();
                  sheetCommentItem.showBottomSheet(
                      context, widget.comment, isAdmin, widget.onDeleteComment);
                },
              ),
            ],
          ),
          Transform.translate(
              offset: const Offset(0, -8), // Negative margin
              child: Container(
                padding: const EdgeInsets.only(
                    left: 42), // Reduced top and bottom padding
                child: Text(
                  widget.comment.comment,
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                ),
              )),
          Padding(
            padding: const EdgeInsets.only(left: 42.0),
            child: Row(
              children: <Widget>[
                GestureDetector(
                    onTap: () {
                      if (widget.isRepliedComment &&
                          widget.onReplyComment != null) {
                        widget.onReplyComment!(widget.comment.user.displayName);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EventCommentRepliesPage(
                                    comment: widget.comment,
                                    isAdmin: widget.isAdmin,
                                    replyTo: widget.comment.user.displayName,
                                  )),
                        );
                      }
                    },
                    child: Text(
                      'Reply',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey[600],
                      ),
                    )),
                const SizedBox(width: 32.0),
                if (repliedCount > 0 && !widget.isRepliedComment)
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EventCommentRepliesPage(
                                    comment: widget.comment,
                                    isAdmin: widget.isAdmin,
                                    replyTo: "",
                                  )),
                        );
                      },
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.reply_all,
                            size: 16.0,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            'View $repliedCount replies',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
