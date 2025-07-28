// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:learningx_flutter_app/api/model/chat_room_model.dart';
// import 'package:learningx_flutter_app/api/model/user_modal.dart';
//
// class ChatRoomItemWidget extends StatefulWidget {
//   final ChatRoom chatRoom;
//   final String currentuserId;
//   const ChatRoomItemWidget(
//       {super.key, required this.chatRoom, required this.currentuserId});
//   @override
//   State<ChatRoomItemWidget> createState() => _ChatRoomItemWidgetState();
// }
//
// class _ChatRoomItemWidgetState extends State<ChatRoomItemWidget> {
//   void handleUnreadCount() {
//     setState(() {
//       widget.chatRoom.unreadCount = 0;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     var receiverAtIndex = 0;
//     var senderAtIndex = 1;
//     if (widget.chatRoom.users[0].id == widget.currentuserId) {
//       receiverAtIndex = 1;
//       senderAtIndex = 0;
//     }
//     User receiver = widget.chatRoom.users[receiverAtIndex];
//     return Container(
//       margin: EdgeInsets.zero,
//       child: Stack(
//         children: [
//           ListTile(
//             leading: CircleAvatar(
//               radius: 20.0,
//               backgroundImage: NetworkImage(
//                   receiver.userImg), // Replace with your image asset
//             ),
//             title: Row(
//               children: [
//                 Flexible(
//                   child: Text(
//                     receiver.displayName,
//                     style: const TextStyle(
//                       fontSize: 16.0,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                       overflow: TextOverflow.visible,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 if (receiver.verified)
//                   const Icon(
//                     Icons.verified_outlined,
//                     size: 15,
//                     color: Colors.blue,
//                   ),
//               ],
//             ),
//             subtitle: Text(
//               widget.chatRoom.lastChat,
//               maxLines: 1,
//             ),
//             onTap: () => {
//               handleUnreadCount(),
//               context.push(
//                   "/chats/${widget.chatRoom.users[receiverAtIndex].id}",
//                   extra: {
//                     'chatRoom': widget.chatRoom,
//                     'receiverAtIndex': receiverAtIndex,
//                     'senderAtIndex': senderAtIndex
//                   })
//             },
//           ),
//           if (widget.chatRoom.unreadCount > 0)
//             Positioned(
//               right: 8.0,
//               top: 18.0,
//               child: Container(
//                 margin: const EdgeInsets.all(4),
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   color: Colors.blue,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 constraints: const BoxConstraints(
//                   minWidth: 16,
//                   minHeight: 18,
//                 ),
//                 child: Text(
//                   '${widget.chatRoom.unreadCount}',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 11,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learningx_flutter_app/api/model/chat_room_model.dart';

class ChatRoomItemWidget extends StatefulWidget {
  final ChatRoom chatRoom;
  final String currentuserId;

  const ChatRoomItemWidget({
    super.key,
    required this.chatRoom,
    required this.currentuserId,
  });

  @override
  State<ChatRoomItemWidget> createState() => _ChatRoomItemWidgetState();
}

class _ChatRoomItemWidgetState extends State<ChatRoomItemWidget> {
  late bool isUnread;

  @override
  void initState() {
    super.initState();
    isUnread = widget.chatRoom.unreadCount > 0;
  }

  void handleTap() {
    setState(() {
      isUnread = false;
    });

    final receiver = widget.chatRoom.users.firstWhere((u) => u.id != widget.currentuserId);
    context.push("/chats/${receiver.id}", extra: {
      'chatRoom': widget.chatRoom,
      'receiverAtIndex': widget.chatRoom.users.indexOf(receiver),
      'senderAtIndex': widget.chatRoom.users.indexWhere((u) => u.id == widget.currentuserId),
    });
  }

  @override
  Widget build(BuildContext context) {
    final otherUser = widget.chatRoom.users.firstWhere((u) => u.id != widget.currentuserId);
    final lastMessage = widget.chatRoom.lastChat ?? 'Say hi 👋';
    final lastTimestamp = widget.chatRoom.lastChatTime;

    return InkWell(
      onTap: handleTap,
      splashColor: Colors.grey.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundImage: NetworkImage(otherUser.userImg ?? ''),
                  backgroundColor: Colors.grey[300],
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          otherUser.displayName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (otherUser.verified)
                        const Icon(Icons.verified, size: 16, color: Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isUnread ? Colors.black : Colors.grey[600],
                      fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTime(lastTimestamp),
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                const SizedBox(height: 4),
                if (isUnread)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${widget.chatRoom.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return '';
    try {
      final time = DateTime.parse(timeString);
      final now = DateTime.now();
      if (now.difference(time).inDays == 0) {
        return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
      } else if (now.difference(time).inDays == 1) {
        return "Yesterday";
      } else {
        return "${time.day}/${time.month}";
      }
    } catch (e) {
      return '';
    }
  }
}
