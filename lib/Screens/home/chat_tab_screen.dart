import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/api/provider/chat_room_provider.dart';
import 'package:learningx_flutter_app/Screens/chats/chat_room_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatTabScreen extends ConsumerStatefulWidget {
  const ChatTabScreen({super.key});

  @override
  ConsumerState<ChatTabScreen> createState() => _ChatTabScreenState();
}

class _ChatTabScreenState extends ConsumerState<ChatTabScreen> {
  String currentUserId = "";

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      currentUserId = prefs.getString('id') ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatRoomsAsync = ref.watch(chatRoomProvider);

    return Scaffold(
      // appBar: AppBar(
      //   //title: const Text('Chats', style: TextStyle(fontWeight: FontWeight.bold)),
      //   backgroundColor: Colors.white,
      //   foregroundColor: Colors.black,
      //   elevation: 0.5,
      // ),
      body: chatRoomsAsync.when(
        data: (chatRooms) {
          final clubChats = chatRooms
              .where((chatRoom) =>
                  chatRoom.users.length > 2 &&
                  chatRoom.users.any((user) => user.id == currentUserId))
              .toList();

          if (clubChats.isEmpty) {
            return const Center(
              child: Text(
                'No conversations yet.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            itemCount: clubChats.length,
            separatorBuilder: (_, __) => const Padding(
              padding: EdgeInsets.only(left: 75, right: 16),
              child: Divider(height: 1, color: Colors.grey),
            ),
            itemBuilder: (context, index) {
              final chatRoom = clubChats[index];

              return ChatRoomItemWidget(
                chatRoom: chatRoom,
                currentuserId: currentUserId,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text('Something went wrong\n${err.toString()}'),
        ),
      ),
    );
  }
}
