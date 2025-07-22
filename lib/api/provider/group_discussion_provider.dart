import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:learningx_flutter_app/api/model/discussion_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupDiscussionNotifier extends StateNotifier<List<Discussion>> {
  final String query;
  GroupDiscussionNotifier(this.query) : super([]) {
    fetchGroupDiscussions();
  }
  bool _isFetching = false;
  bool _hasMore = true;
  // ignore: avoid_init_to_null, unused_field
  var _lastDocId = null;

  bool get isLoading => _isFetching;

  Future<void> fetchGroupDiscussions() async {
    if (_isFetching || !_hasMore) return;

    _isFetching = true;
    var url =
        '${dotenv.env['BASE_API_URL']}/clubs/$query';
    if (_lastDocId != null) {
      url =
          '${dotenv.env['BASE_API_URL']}/clubs/$query&_id[\$lt]=$_lastDocId';
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List jsonChats = data['chats'];
      bool moreChats = data['moreChats'];
      _lastDocId = data['lastDocId'];

      final newChats =
          jsonChats.map((chat) => Discussion.fromJson(chat)).toList();
      state = [...state, ...newChats];
      _hasMore = moreChats;
    } else {
      throw Exception('Failed to load chats');
    }

    _isFetching = false;
  }

  void addGroupChat(Discussion chat) {
    state = [chat, ...state];
  }
  void deleteChat(String chatId) {
    state = state.where((chat) => chat.id != chatId).toList();
  }

  Future<void> refreshChats() async {
    // Resetting the fetch state for a fresh start
    _hasMore = true;
    _lastDocId = null;
    state = []; // Clear current state to reload notifications
    await fetchGroupDiscussions();
  }
}

final groupDiscussionProvider = StateNotifierProvider.family<
    GroupDiscussionNotifier, List<Discussion>, String>((ref, query) {
  return GroupDiscussionNotifier(query);
});
