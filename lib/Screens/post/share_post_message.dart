import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/chats/chat_page.dart';
import 'package:learningx_flutter_app/api/model/chat_room_model.dart';
import 'package:learningx_flutter_app/api/model/user_modal.dart';
import 'package:learningx_flutter_app/api/provider/chat_room_provider.dart';

class SharePostMessageScreen extends ConsumerWidget {
  final String currentuserId;
  final String link;
  const SharePostMessageScreen(
      {super.key, required this.currentuserId, required this.link});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatRoomAsyncValue = ref.watch(chatRoomProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select a chat"),
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
      ),
      body: Center(
        child: chatRoomAsyncValue.when(
          data: (rooms) {
            return ListView.builder(
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                ChatRoom chatRoom = rooms[index];
                var receiverAtIndex = 0;
                var senderAtIndex = 1;
                if (chatRoom.users[0].id == currentuserId) {
                  receiverAtIndex = 1;
                  senderAtIndex = 0;
                }
                User receiver = chatRoom.users[receiverAtIndex];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 20.0,
                    backgroundImage: NetworkImage(
                        receiver.userImg), // Replace with your image asset
                  ),
                  title: Text(receiver.displayName),
                  subtitle: Text(
                    chatRoom.lastChat,
                    maxLines: 1,
                  ),
                  onTap: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChatActivity(
                                chatRoom: chatRoom,
                                receiverAtIndex: receiverAtIndex,
                                senderAtIndex: senderAtIndex,
                                chat: link,
                              )),
                    )
                  },
                );
              },
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text('Failed to fetch clubs: $error'),
        ),
      ),
    );
  }
}
