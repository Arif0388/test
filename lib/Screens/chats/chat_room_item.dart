import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learningx_flutter_app/api/model/chat_room_model.dart';
import 'package:learningx_flutter_app/api/model/user_modal.dart';

class ChatRoomItemWidget extends StatefulWidget {
  final ChatRoom chatRoom;
  final String currentuserId;
  const ChatRoomItemWidget(
      {super.key, required this.chatRoom, required this.currentuserId});
  @override
  State<ChatRoomItemWidget> createState() => _ChatRoomItemWidgetState();
}

class _ChatRoomItemWidgetState extends State<ChatRoomItemWidget> {
  void handleUnreadCount() {
    setState(() {
      widget.chatRoom.unreadCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    var receiverAtIndex = 0;
    var senderAtIndex = 1;
    if (widget.chatRoom.users[0].id == widget.currentuserId) {
      receiverAtIndex = 1;
      senderAtIndex = 0;
    }
    User receiver = widget.chatRoom.users[receiverAtIndex];
    return Container(
      margin: EdgeInsets.zero,
      child: Stack(
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 20.0,
              backgroundImage: NetworkImage(
                  receiver.userImg), // Replace with your image asset
            ),
            title: Row(
              children: [
                Flexible(
                  child: Text(
                    receiver.displayName,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (receiver.verified)
                  const Icon(
                    Icons.verified_outlined,
                    size: 15,
                    color: Colors.blue,
                  ),
              ],
            ),
            subtitle: Text(
              widget.chatRoom.lastChat,
              maxLines: 1,
            ),
            onTap: () => {
              handleUnreadCount(),
              context.push(
                  "/chats/${widget.chatRoom.users[receiverAtIndex].id}",
                  extra: {
                    'chatRoom': widget.chatRoom,
                    'receiverAtIndex': receiverAtIndex,
                    'senderAtIndex': senderAtIndex
                  })
            },
          ),
          if (widget.chatRoom.unreadCount > 0)
            Positioned(
              right: 8.0,
              top: 18.0,
              child: Container(
                margin: const EdgeInsets.all(4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 18,
                ),
                child: Text(
                  '${widget.chatRoom.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
