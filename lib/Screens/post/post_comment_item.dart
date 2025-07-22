import 'package:flutter/material.dart';
import 'package:learningx_flutter_app/api/model/comment_model.dart';
import 'package:learningx_flutter_app/api/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommentItemWidget extends StatefulWidget {
  final PostComment comment;
  final void Function(String) onDeleteComment;
  const CommentItemWidget(
      {super.key, required this.comment, required this.onDeleteComment});
  @override
  State<CommentItemWidget> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItemWidget> {
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
      isAdmin = widget.comment.user.id == _currentUserId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(width: 4.0),
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(widget.comment.user.userImg),
                backgroundColor: Colors.transparent,
              ),
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
            ],
          ),
          Transform.translate(
              offset: const Offset(0, -4), // Negative margin
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
        ],
      ),
    );
  }
}
