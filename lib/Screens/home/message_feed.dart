import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/chats/chat_room_item.dart';
import 'package:learningx_flutter_app/Screens/chats/new_chat_page.dart';
import 'package:learningx_flutter_app/Screens/home/empty_message_feed.dart';
import 'package:learningx_flutter_app/api/model/chat_room_model.dart';
import 'package:learningx_flutter_app/api/provider/chat_room_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  var currentUserId = "";

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getString('id') ?? "";
    });
  }

  Future<void> _refresh() async {
    await ref.refresh(chatRoomProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final chatRoomAsyncValue = ref.watch(chatRoomProvider);

    return Scaffold(
        body: Center(
          child: chatRoomAsyncValue.when(
            data: (rooms) {
              if (rooms.isEmpty) {
                return const EmptyMessageFeed();
              } else {
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    itemCount: rooms.length,
                    itemBuilder: (context, index) {
                      ChatRoom chatRoom = rooms[index];
                      return ChatRoomItemWidget(
                          chatRoom: chatRoom, currentuserId: currentUserId);
                    },
                  ),
                );
              }
            },
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => const Text('Failed to fetch chat rooms'),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color.fromARGB(255, 56, 114, 220),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NewChatPage(),
              ),
            );
          },
          child: const Icon(
            Icons.add_comment,
            color: Colors.white,
          ),
        ));
  }
}
