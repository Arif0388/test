// ignore_for_file: library_prefixes

import 'dart:collection';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/chats/bottom_sheet_chat_page.dart';
import 'package:learningx_flutter_app/Screens/chats/chat_item.dart';
import 'package:learningx_flutter_app/Screens/common/bottom_sheet_select_filetype.dart';
import 'package:learningx_flutter_app/api/model/chat_model.dart';
import 'package:learningx_flutter_app/api/model/chat_room_model.dart';
import 'package:learningx_flutter_app/api/model/user_modal.dart';
import 'package:learningx_flutter_app/api/provider/chat_provider.dart';
import 'package:learningx_flutter_app/api/provider/chat_room_provider.dart';
import 'package:learningx_flutter_app/api/utils/utils.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatActivity extends ConsumerStatefulWidget {
  final ChatRoom chatRoom;
  final int receiverAtIndex;
  final int senderAtIndex;
  final String? chat;

  const ChatActivity(
      {super.key,
      required this.chatRoom,
      required this.receiverAtIndex,
      required this.senderAtIndex,
      this.chat});

  @override
  ConsumerState<ChatActivity> createState() => _ChatActivityState();
}

class _ChatActivityState extends ConsumerState<ChatActivity> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  late ChatRoom currentChatRoom;
  var _currentUserId = "";
  var receiverId = "";
  bool _hasText = false;

  IO.Socket? socket;
  String apiUrl = dotenv.env['BASE_API_URL'] ?? "";

  var lastSeenBy = [];

  @override
  void initState() {
    super.initState();
    currentChatRoom = widget.chatRoom;
    User user = currentChatRoom.users[widget.senderAtIndex];
    User receiver = currentChatRoom.users[widget.receiverAtIndex];
    setState(() {
      _currentUserId = user.id;
      receiverId = receiver.id;
      lastSeenBy.add(user.id);
    });
    _scrollController.addListener(_scrollListener);
    if (currentChatRoom.id != "id") {
      markReadChatsApi(context, currentChatRoom.id);
      _connectToWebSocket();
    }
    if (widget.chat != null) {
      _messageController.text = widget.chat!;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
    _messageController.addListener(() {
      setState(() {
        _hasText = _messageController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    socket?.off('message', _handleMessage);
    socket?.disconnect();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(chatProvider(currentChatRoom.id).notifier).fetchChats();
    }
  }

  void _connectToWebSocket() {
    if (socket != null && socket!.connected) {
      log("Socket already connected");
      return;
    }

    log("Initializing WebSocket...");
    socket = IO.io(apiUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket!.connect();

    User user = currentChatRoom.users[widget.senderAtIndex];

    // Prevent duplicate listeners
    socket!.off('message'); // Remove existing listener
    socket!.off('roomUsers'); // Remove existing listener

    socket!.on('message', _handleMessage);
    socket!.on('roomUsers', (data) {
      log('Room users: $data');
      _handleRoomUsers(data);
    });

    socket!.emit('joinRoom', {
      'sender': {
        '_id': user.id,
        'firstname': user.firstname,
        'lastname': user.lastname,
        'displayName': user.displayName,
        'userImg': user.userImg,
        'verified': user.verified
      },
      'room': currentChatRoom.id,
    });
  }

  void _handleRoomUsers(dynamic data) {
    if (data is Map && data.containsKey('users')) {
      var users = data['users'];
      if (users is List) {
        for (var user in users) {
          var sender = user['sender'];
          if (sender is Map && sender.containsKey('_id')) {
            var userId = sender['_id'];
            if (!lastSeenBy.contains(userId)) {
              setState(() {
                lastSeenBy.add(userId);
              });
            }
          }
        }
      }
    } else {
      log("Invalid data format for roomUsers: $data");
    }
  }

  void _handleMessage(chatData) {
    if (!mounted) return;

    try {
      // Print raw data for debugging purposes
      print(chatData);

      if (chatData.containsKey('sender')) {
        final senderData = chatData['sender'];

        // Create User object from senderData
        final sender = User(
          id: senderData['_id'],
          username: "username",
          firstname: senderData['firstname'],
          lastname: senderData['lastname'],
          displayName: senderData['displayName'],
          userImg: senderData['userImg'],
          userNameId: 'userNameId',
          googleId: 'googleId',
          verified: senderData['verified'] ?? false,
        );

        // Create Chat object from chatData
        final chat = Chat(
          id: chatData['_id'],
          sender: sender,
          chat: chatData['chat'],
          room: currentChatRoom.id,
          file: chatData['file'] ?? "",
          filetype: chatData['filetype'],
          filename: chatData['filename'] ?? "",
          filesize: chatData['filesize'] ?? "",
          realFiletype: chatData['realFiletype'] ?? "",
          createdAt: chatData['createdAt'],
        );

        // Update chatProvider with the new chat
        if (mounted) {
          ref.read(chatProvider(currentChatRoom.id).notifier).addChat(chat);
        }
      } else {
        log('Error: "sender" key not found in chatData');
      }
    } catch (e) {
      // Handle any errors during decoding or processing
      log('Error processing incoming message: $e');
    }
  }

  void _sendMessage(String message) async {
    if (message.isNotEmpty) {
      Map<String, dynamic> map = HashMap();
      map['chat'] = message;
      map['filetype'] = 'text';
      map['seenBy'] = lastSeenBy;
      _messageController.clear();

      if (currentChatRoom.id != "id") {
        map['room'] = currentChatRoom.id;
        String chatId = await sendChat(map);
        map['_id'] = chatId;
        socket!.emit('chatMessage', map);
      } else {
        // Create a new chat room
        Map<String, dynamic> room = HashMap();
        room['users'] = [
          currentChatRoom.users[widget.senderAtIndex].id,
          currentChatRoom.users[widget.receiverAtIndex].id,
        ];
        room['lastSeenBy'] = [currentChatRoom.users[widget.senderAtIndex].id];
        room['lastChat'] = message;

        // Create the chat room and get its ID
        String roomId = await createChatRoomApi(context, room);

        // Update state with the new chat room ID
        setState(() {
          currentChatRoom = currentChatRoom.copyWith(chatRoomId: roomId);
        });

        // Establish a WebSocket connection for the new room
        _connectToWebSocket();

        map['room'] = roomId;
        await sendChat(map);
      }
    }
  }

  Future<void> _refresh() async {
    ref.read(chatProvider(currentChatRoom.id).notifier).refreshChats();
  }

  Future<void> updateChatRoom() async {
    setState(() {
      final updatedBlockedBy =
          currentChatRoom.blockedBy!.contains(_currentUserId)
              ? (List<String>.from(currentChatRoom.blockedBy!)
                ..remove(_currentUserId))
              : (List<String>.from(currentChatRoom.blockedBy!)
                ..add(_currentUserId));
      currentChatRoom.blockedBy = updatedBlockedBy;
      Map<String, dynamic> map = HashMap();
      map['_id'] = currentChatRoom.id;
      map['blockedBy'] = updatedBlockedBy;
      updateChatRoomApi(context, map);
    });
  }

  @override
  Widget build(BuildContext context) {
    final chats = ref.watch(chatProvider(currentChatRoom.id));
    final isLoading = ref.watch(chatProvider(currentChatRoom.id)
        .notifier
        .select((state) => state.isLoading));
    final List<Widget> appBarActions = [
      IconButton(
        icon: const Icon(Icons.more_horiz),
        onPressed: () {
          final BottomSheetChatPage sheetChatPage = BottomSheetChatPage();
          sheetChatPage.showBottomSheet(
              context,
              currentChatRoom,
              widget.receiverAtIndex,
              updateChatRoom,
              currentChatRoom.blockedBy!.contains(_currentUserId));
        },
      ),
      const SizedBox(
        width: 8,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Flexible(
              child: Text(
                currentChatRoom.users[widget.receiverAtIndex].displayName,
              ),
            ),
            const SizedBox(width: 8),
            if (currentChatRoom.users[widget.receiverAtIndex].verified)
              const Icon(
                Icons.verified_outlined,
                size: 15,
                color: Colors.blue,
              ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
        actions: appBarActions,
      ),
      body: Column(
        children: [
          Expanded(
              child: Center(
            child: isLoading
                ? const CircularProgressIndicator()
                : chats.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'No chats available',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      )
                    : ListView.builder(
                        key: const PageStorageKey<String>('chatList'),
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.all(12),
                        itemCount: chats.length + (isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == chats.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final currentMillis = chats[index].createdAtDate;
                          final nextMillis = index < chats.length - 1
                              ? chats[index + 1].createdAtDate
                              : null;
                          bool showDate = nextMillis == null ||
                              !Utils.isSameDay(currentMillis, nextMillis);
                          Chat chat = chats[index];
                          bool isSelf = chat.sender.id == _currentUserId;
                          return ChatItemWidget(
                              chat: chat, showDate: showDate, isSelf: isSelf);
                        },
                      ),
          )),
          if (currentChatRoom.blockedBy!.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.blue),
                    onPressed: () {
                      final SelectFiletypeBottomSheet bottomSheet =
                          SelectFiletypeBottomSheet();
                      bottomSheet.showBottomSheet(
                          context, "chat", null, null, currentChatRoom, socket);
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor:
                          _hasText ? Colors.blue : Colors.blue.withOpacity(0.5),
                      child: IconButton(
                        icon:
                            const Icon(Icons.arrow_upward, color: Colors.white),
                        onPressed: () {
                          _sendMessage(_messageController.text);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (currentChatRoom.blockedBy!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              alignment: Alignment.center,
              color: Colors.blue,
              child: Text(currentChatRoom.blockedBy!.contains(_currentUserId)
                  ? "You have blocked ${currentChatRoom.users[widget.receiverAtIndex].displayName}"
                  : "You are blocked by ${currentChatRoom.users[widget.receiverAtIndex].displayName}"),
            )
        ],
      ),
    );
  }
}
