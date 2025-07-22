// ignore_for_file: library_prefixes

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/club/discussion/discussion_item.dart';
import 'package:learningx_flutter_app/Screens/common/bottom_sheet_select_filetype.dart';
import 'package:learningx_flutter_app/api/model/discussion_model.dart';
import 'package:learningx_flutter_app/api/model/member_model.dart';
import 'package:learningx_flutter_app/api/model/user_modal.dart';
import 'package:learningx_flutter_app/api/provider/channel_member_provider.dart';
import 'package:learningx_flutter_app/api/provider/discussion_provider.dart';
import 'package:learningx_flutter_app/api/provider/group_discussion_provider.dart';
import 'package:learningx_flutter_app/api/utils/utils.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class GroupDiscussionActivity extends ConsumerStatefulWidget {
  final Discussion parentChat;
  final void Function(bool) onHandleSocket;
  const GroupDiscussionActivity(
      {super.key, required this.parentChat, required this.onHandleSocket});

  @override
  ConsumerState<GroupDiscussionActivity> createState() =>
      _GroupDiscussionActivityState();
}

class _GroupDiscussionActivityState
    extends ConsumerState<GroupDiscussionActivity> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  IO.Socket? iosocket;
  String apiUrl = dotenv.env['BASE_API_URL'] ?? "";
  var _currentUserId = "";
  var _currentFirstname = "user";
  var _currentLastname = "_name";
  var _currentUserName = "user_name";
  var _currentUserImg = "";
  var lastSeenBy = [];
  bool isAllowedToDelete = false;
  bool isCurrentUser = false;
  late List<Member> _members = [];
  List<Member> _suggestions = [];
  bool _showSuggestions = false;
  bool _hasText = false;

  Map<int, dynamic> mentionPositions = {}; // Position as key, userId as value

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _messageController.addListener(_onTextChanged);
    // Schedule initialization after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  Future<void> _initialize() async {
    await _loadCurrentUser();
    _connectToWebSocket();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    iosocket?.off('message', _handleMessage);
    iosocket?.disconnect();
    widget.onHandleSocket(false);
    super.dispose();
  }

  // Load counter value from SharedPreferences
  _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('id') ?? "";
      _currentFirstname = prefs.getString("firstname") ?? "";
      _currentLastname = prefs.getString("lastname") ?? "";
      _currentUserName = prefs.getString('displayName') ?? "";
      _currentUserImg = prefs.getString("userImg") ?? "";
      lastSeenBy.add(_currentUserId);
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref
          .read(groupDiscussionProvider(
                  "${widget.parentChat.channel}/discussions?parentChatId=${widget.parentChat.id}")
              .notifier)
          .fetchGroupDiscussions();
    }
  }

  void _onTextChanged() {
    final text = _messageController.text;
    final cursorPos = _messageController.selection.baseOffset;

    setState(() {
      _hasText = _messageController.text.trim().isNotEmpty;
    });

    if (cursorPos > 0 && text[cursorPos - 1] == '@') {
      setState(() {
        _showSuggestions = true;
        final query = text.substring(cursorPos).trim();
        _suggestions = _members.where((member) {
          return member.user.displayName
              .toLowerCase()
              .contains(query.toLowerCase());
        }).toList();
      });
    } else {
      final atIndex = text.lastIndexOf('@');
      if (atIndex != -1 && cursorPos > atIndex) {
        final query = text.substring(atIndex + 1, cursorPos).trim();
        setState(() {
          _showSuggestions = true;
          _suggestions = _members.where((member) {
            return member.user.displayName
                .toLowerCase()
                .contains(query.toLowerCase());
          }).toList();
        });
      } else {
        setState(() {
          _showSuggestions = false;
        });
      }
    }
  }

  void _insertMention(String displayName, String userId) {
    final currentText = _messageController.text;
    final startPosition = _messageController.selection.baseOffset;

    // Find the position of '@' before the cursor
    int atPosition = currentText.lastIndexOf('@', startPosition);

    if (atPosition != -1) {
      // Find the next space or end of text after '@'
      int endAtPosition = currentText.indexOf(' ', atPosition);
      if (endAtPosition == -1) {
        endAtPosition = currentText.length;
      }

      // Replace from '@' to the end of the text after '@' with the displayName
      final updatedText = currentText.replaceRange(
          atPosition + 1, endAtPosition, "$displayName ");

      _messageController.text = updatedText;

      // Update the cursor position to be at the end of the inserted mention
      final endPosition = atPosition + displayName.length + 2;
      _messageController.selection =
          TextSelection.fromPosition(TextPosition(offset: endPosition));

      // Store the userId with the starting position and length of the mention
      mentionPositions[atPosition + 1] = {
        'userId': userId,
        'length': displayName.length
      };
    }
  }

  void _connectToWebSocket() {
    iosocket = IO.io(apiUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    iosocket!.connect();

    iosocket!.emit(
      'joinRoom',
      {
        'sender': {
          '_id': _currentUserId,
          'firstname': _currentFirstname,
          'lastname': _currentLastname,
          'displayName': _currentUserName,
          'userImg': _currentUserImg,
          'verified': false
        },
        'room': widget.parentChat.id,
      },
    );

    iosocket!.on('message', _handleMessage);

    iosocket!.on('roomUsers', (data) {
      print('Room users: $data');
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
      }
    });
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
        final chat = Discussion(
          id: chatData['_id'],
          sender: sender,
          club: widget.parentChat.club,
          channel: widget.parentChat.channel,
          parentChatId: widget.parentChat.id,
          chat: chatData['chat'],
          repliedCount: 0,
          file: chatData['file'] ?? "",
          filetype: chatData['filetype'],
          filename: chatData['filename'] ?? "",
          filesize: chatData['filesize'] ?? "",
          realFiletype: "chatData['realFiletype']",
          createdAt: chatData['createdAt'],
        );

        // Update chatProvider with the new chat
        if (mounted) {
          ref
              .read(groupDiscussionProvider(
                      "${widget.parentChat.channel}/discussions?parentChatId=${widget.parentChat.id}")
                  .notifier)
              .addGroupChat(chat);
        }
      } else {
        print('Error: "sender" key not found in chatData');
      }
    } catch (e) {
      // Handle any errors during decoding or processing
      print('Error processing incoming message: $e');
    }
  }

  void deleteChat(String chatId) {
    ref
        .read(groupDiscussionProvider(
                "${widget.parentChat.channel}/discussions?parentChatId=${widget.parentChat.id}")
            .notifier)
        .deleteChat(chatId);
  }

  void _sendChat(String message) async {
    if (message.isNotEmpty) {
      String formattedMessage = message;

      // Sort positions in reverse order to handle replacements correctly
      var sortedPositions = mentionPositions.keys.toList()
        ..sort((a, b) => b.compareTo(a));

      for (int position in sortedPositions) {
        final userId = mentionPositions[position]!['userId'];
        final displayNameLength = mentionPositions[position]!['length'] as int;

        // Ensure the position and length are within the bounds of the message
        if (position + displayNameLength <= formattedMessage.length) {
          // Extract the supposed displayName from the message
          final supposedDisplayName = formattedMessage.substring(
              position, position + displayNameLength);

          // Check if the extracted displayName matches the expected one
          if (supposedDisplayName ==
              message.substring(position, position + displayNameLength)) {
            // Replace with HTML mention
            final mentionHtml =
                '<a href="profile://$userId">$supposedDisplayName</a>';
            formattedMessage = formattedMessage.replaceRange(
                position, position + displayNameLength, mentionHtml);
          }
        }
      }

      Map<String, dynamic> map = HashMap();
      map['channel'] = widget.parentChat.channel;
      map['club'] = widget.parentChat.club;
      map['parentChatId'] = widget.parentChat.id;
      map['chat'] = formattedMessage;
      map['filetype'] = 'text';
      map['seenBy'] = lastSeenBy;
      _messageController.clear();
      String chatId = await sendDiscussion(map);
      map['_id'] = chatId;
      iosocket!.emit('chatMessage', map);
      mentionPositions.clear(); // Clear mentions map after sending
    }
  }

  Future<void> _refresh() async {
    ref
        .read(groupDiscussionProvider(
                "${widget.parentChat.channel}/discussions?parentChatId=${widget.parentChat.id}")
            .notifier)
        .refreshChats();
  }

  @override
  Widget build(BuildContext context) {
    final chats = ref.watch(groupDiscussionProvider(
        "${widget.parentChat.channel}/discussions?parentChatId=${widget.parentChat.id}"));
    final isLoading = ref.watch(groupDiscussionProvider(
            "${widget.parentChat.channel}/discussions?parentChatId=${widget.parentChat.id}")
        .notifier
        .select((state) => state.isLoading));
    final channelmembers = ref
        .watch(channelMemberProvider("${widget.parentChat.channel}/members"));
    setState(() {
      _members = channelmembers;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.parentChat.title ?? "Discussions"),
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
      ),
      body: Column(
        children: [
          Expanded(
              child: Stack(children: [
            Center(
              child: isLoading
                  ? const CircularProgressIndicator()
                  : chats.isEmpty
                      ? const Text('No chats available')
                      : ListView.builder(
                          key: const PageStorageKey<String>(
                              'groupDiscussionList'),
                          controller: _scrollController,
                          reverse: true,padding: const EdgeInsets.only(
                                left: 8, right: 16, bottom: 8),
                          itemCount: chats.length + (isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == chats.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              );
                            }
                            final currentMillis = chats[index].createdAtDate;
                            final nextMillis = index < chats.length - 1
                                ? chats[index + 1].createdAtDate
                                : null;
                            bool showDate = nextMillis == null ||
                                !Utils.isSameDay(currentMillis, nextMillis);
                            Discussion chat = chats[index];
                            isCurrentUser = chat.sender.id == _currentUserId;
                            return DiscussionItemWidget(
                                chat: chat,
                                showDate: showDate,
                                isAllowedToDelete:
                                    isAllowedToDelete || isCurrentUser,
                                isCurrentUser: isCurrentUser,
                                onDeleteChat: deleteChat);
                          },
                        ),
            ),
            if (_showSuggestions)
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: Material(
                  elevation: 5,
                  child: SizedBox(
                    height: _suggestions.length > 6
                        ? 300
                        : _suggestions.length * 50,
                    child: ListView.builder(
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        final member = _suggestions[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(member.user.userImg),
                          ),
                          title: Text(member.user.displayName),
                          onTap: () => _insertMention(
                              member.user.displayName, member.user.id),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ])),
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
                    bottomSheet.showBottomSheet(context, "groupDiscussion",
                        widget.parentChat, null, null, iosocket);
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
                      icon: const Icon(Icons.arrow_upward, color: Colors.white),
                      onPressed: () {
                        _sendChat(_messageController.text);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
