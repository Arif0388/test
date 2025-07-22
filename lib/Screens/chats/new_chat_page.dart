import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/chats/chat_page.dart';
import 'package:learningx_flutter_app/api/model/chat_room_model.dart';
import 'package:learningx_flutter_app/api/model/user_modal.dart';
import 'package:learningx_flutter_app/api/provider/chat_room_provider.dart';
import 'package:learningx_flutter_app/api/provider/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewChatPage extends ConsumerStatefulWidget {
  const NewChatPage({super.key});
  @override
  ConsumerState<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends ConsumerState<NewChatPage> {
  String _searchQuery = "";
  String _collegeId = "";
  String _currentUserId = "";
  var _currentFirstname = "user";
  var _currentLastname = "_name";
  var _currentUserName = "user_name";
  var _currentUserImg = "";
  List<User> oldChatRoom = [];

  @override
  void initState() {
    _loadCurrentUser();
    super.initState();
  }

  _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString("id") ?? "";
      _collegeId = prefs.getString("college") ?? "";
      _currentFirstname = prefs.getString("firstname") ?? "";
      _currentLastname = prefs.getString("lastname") ?? "";
      _currentUserName = prefs.getString('displayName') ?? "";
      _currentUserImg = prefs.getString("userImg") ?? "";
    });
  }

  void _filterItems(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatRoomAsyncValue = ref.watch(chatRoomProvider);

    chatRoomAsyncValue.whenData((data) {
      oldChatRoom.clear();
      for (int i = 0; i < data.length; i++) {
        if (data[i].users[0].id == _currentUserId) {
          oldChatRoom.add(data[i].users[1]);
        } else {
          oldChatRoom.add(data[i].users[0]);
        }
      }
    });

    final userAsyncValue = ref.watch(userProvider(_searchQuery.isNotEmpty
        ? "?displayName[\$regex]=.*$_searchQuery.*&displayName[\$options]=i&_id[\$ne]=$_currentUserId"
        : "?_id[\$ne]=$_currentUserId&college=$_collegeId"));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
        title: const Text("New Chat"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                contentPadding: const EdgeInsets.all(8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                _filterItems(value);
              },
            ),
            const SizedBox(height: 8),
            Expanded(
              child: userAsyncValue.when(
                data: (data) {
                  final filteredData = data.where((user) {
                    return !oldChatRoom.any((oldUser) => oldUser.id == user.id);
                  }).toList();
                  return ListView.builder(
                    itemCount: filteredData.length,
                    itemBuilder: (context, index) {
                      User user = filteredData[index];
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 20.0,
                          backgroundImage: NetworkImage(user.userImg),
                        ),
                        title: Text(user.displayName),
                        subtitle: Text(user.userNameId),
                        onTap: () => {
                          Navigator.pop(context),
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatActivity(
                                chatRoom: ChatRoom(
                                    id: 'id',
                                    users: [
                                      user,
                                      User(
                                          id: _currentUserId,
                                          username: 'username',
                                          firstname: _currentFirstname,
                                          lastname: _currentLastname,
                                          displayName: _currentUserName,
                                          userImg: _currentUserImg,
                                          userNameId: 'userNameId',
                                          googleId: 'googleId',
                                          verified: false)
                                    ],
                                    lastChat: 'lastChat',
                                    lastChatTime: '',
                                    unreadCount: 0,
                                    blockedBy: []),
                                senderAtIndex: 1,
                                receiverAtIndex: 0,
                              ),
                            ),
                          )
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) =>
                    Center(child: Text('Failed to fetch users: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
