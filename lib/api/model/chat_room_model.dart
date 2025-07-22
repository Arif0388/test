import 'package:learningx_flutter_app/api/model/user_modal.dart';

class ChatRoom {
  final String id;
  final List<User> users;
  final String lastChat;
  final String lastChatTime;
  late int unreadCount;
  late List<String>? blockedBy;

  ChatRoom(
      {required this.id,
      required this.users,
      required this.lastChat,
      required this.lastChatTime,
      required this.unreadCount,
      this.blockedBy});

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['_id'],
      users: List<User>.from(
          json['users'].map((itemJson) => User.fromJson(itemJson))),
      lastChat: json['lastChat'],
      lastChatTime: json['lastChatTime'],
      unreadCount: json['unreadCount'],
      blockedBy:
          json['blockedBy'] != null ? List<String>.from(json['blockedBy']) : [],
    );
  }

  ChatRoom copyWith({String? chatRoomId, List<String>? updatedBlockedBy}) {
    return ChatRoom(
        id: chatRoomId ?? id,
        users: users,
        lastChat: lastChat,
        lastChatTime: lastChatTime,
        unreadCount: unreadCount,
        blockedBy: updatedBlockedBy ?? blockedBy);
  }
}
