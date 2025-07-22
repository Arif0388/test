import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learningx_flutter_app/Screens/club/discussion/group_discussion_page.dart';
import 'package:learningx_flutter_app/Screens/common/bottom_sheet_chat_item.dart';
import 'package:learningx_flutter_app/Style/custom_style.dart';
import 'package:learningx_flutter_app/api/common/full_image_page.dart';
import 'package:learningx_flutter_app/api/model/discussion_model.dart';
import 'package:learningx_flutter_app/api/utils/utils.dart';

class GroupDiscussionItem extends StatefulWidget {
  final Discussion chat;
  final bool showDate;
  final bool isAllowedToDelete;
  final bool isCurrentUser;
  final void Function(String) onDeleteChat;
  final void Function(bool) onHandleSocket;

  const GroupDiscussionItem({
    super.key,
    required this.chat,
    required this.showDate,
    required this.isAllowedToDelete,
    required this.isCurrentUser,
    required this.onDeleteChat,
    required this.onHandleSocket,
  });

  @override
  State<GroupDiscussionItem> createState() => _GroupDiscussionItemState();
}

class _GroupDiscussionItemState extends State<GroupDiscussionItem> {

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showDate)
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              Utils.getDateString(widget.chat.createdAtDate),
              style: const TextStyle(
                color: Color(0xFF272728),
                fontSize: 14.0,
              ),
            ),
          ),

        // Main Chat Content
        Align(
          alignment: widget.isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.85,
            ),
            child: Row(
              mainAxisAlignment:
                  widget.isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!widget.isCurrentUser)
                  GestureDetector(
                    onTap: () =>
                        context.push("/profile/${widget.chat.sender.id}"),
                    child: CircleAvatar(
                      radius: 16.0,
                      backgroundImage: widget.chat.sender.userImg != ""
                          ? NetworkImage(widget.chat.sender.userImg)
                          : null,
                      backgroundColor: Colors.grey[300], // Placeholder color
                    ),
                  ),
                const SizedBox(width: 8),

                // Message Container
                Flexible(
                    child: GestureDetector(
                  onLongPress: () {
                    final BottomSheetChatItem sheetChatItem =
                        BottomSheetChatItem();
                    sheetChatItem.showBottomSheet(
                        context, widget.chat, widget.onDeleteChat, widget.isAllowedToDelete);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          widget.isCurrentUser ? AppColors.messageBubbleBlue : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _buildMessageContent(context),
                  ),
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Prevent infinite height
      children: [
        if (!widget.isCurrentUser)
          Text(
            widget.chat.sender.displayName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.0,
              color: AppColors.primaryBlue,
            ),
          ),
        const SizedBox(height: 4.0),
        Text(
          widget.chat.title ?? "",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        if (widget.chat.chat.isNotEmpty)
          Text(
            widget.chat.chat,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black,
            ),
          ),
        const SizedBox(height: 4),
        if (widget.chat.filetype == "image" && widget.chat.file != null)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullImagePage(
                    url: widget.chat.file!,
                    displayName: widget.chat.sender.displayName,
                  ),
                ),
              );
            },
            child: Image.network(
              widget.chat.file!,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 50, color: Colors.grey),
            ),
          ),
        const Divider(
          thickness: 1,
          color: Color(0xFF7C7C7C),
        ),
        Row(
          children: [
            Text(
              Utils.getTimeString(widget.chat.createdAtDate),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "• ${widget.chat.repliedCount} replies",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                widget.onHandleSocket(true);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupDiscussionActivity(
                      parentChat: widget.chat,
                      onHandleSocket: widget.onHandleSocket,
                    ),
                  ),
                );
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.reply,
                    size: 20,
                    color: Color(0xFF4285F4),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Start Discussion',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF4285F4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
