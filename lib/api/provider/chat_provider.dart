import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:learningx_flutter_app/api/model/chat_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatNotifier extends StateNotifier<List<Chat>> {
  final String roomId;
  ChatNotifier(this.roomId) : super([]) {
    fetchChats();
  }

  bool _isFetching = false;
  bool _hasMore = true;
  // ignore: prefer_typing_uninitialized_variables
  var _lastDocId;

  bool get isLoading => _isFetching;

  Future<void> fetchChats() async {
    if (_isFetching || !_hasMore) return;

    _isFetching = true;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var url = '${dotenv.env['BASE_API_URL']}/chats/$roomId';
    if (_lastDocId != null) {
      url = '${dotenv.env['BASE_API_URL']}/chats/$roomId?_id[\$lt]=$_lastDocId';
    }

    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List jsonChats = data['chats'];
      bool moreChats = data['moreChats'];
      _lastDocId = data['lastDocId'];

      final newChats = jsonChats.map((chat) => Chat.fromJson(chat)).toList();
      state = [...state, ...newChats];
      _hasMore = moreChats;
    } else {
      throw Exception('Failed to load chats');
    }

    _isFetching = false;
  }

  void addChat(Chat chat) {
    state = [chat, ...state];
  }

  Future<void> refreshChats() async {
    // Resetting the fetch state for a fresh start
    _hasMore = true;
    _lastDocId = null;
    state = []; // Clear current state to reload notifications
    await fetchChats();
  }
}

final chatProvider =
    StateNotifierProvider.family<ChatNotifier, List<Chat>, String>(
        (ref, roomId) {
  return ChatNotifier(roomId);
});

Future<String> sendChat(Map<String, dynamic> data) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var url = dotenv.env['BASE_API_URL'];
  final response = await http.post(
    Uri.parse("$url/chats/${data['room']}"),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: json.encode(data),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['_id'];
  } else {
    throw Exception('Failed to send chat');
  }
}
