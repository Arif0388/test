import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:learningx_flutter_app/api/model/discussion_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiscussionNotifier extends StateNotifier<List<Discussion>> {
  final String query;
  DiscussionNotifier(this.query) : super([]) {
    fetchDiscussions();
  }
  bool _isFetching = false;
  bool _hasMore = true;
  // ignore: avoid_init_to_null, unused_field
  var _lastDocId = null;

  bool get isLoading => _isFetching;

  Future<void> fetchDiscussions() async {
    if (_isFetching || !_hasMore) return;

    _isFetching = true;
    var url = '${dotenv.env['BASE_API_URL']}/clubs/$query';
    if (_lastDocId != null) {
      url = '${dotenv.env['BASE_API_URL']}/clubs/$query&_id[\$lt]=$_lastDocId';
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
      print(data);
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

  void addChat(Discussion chat) {
    state = [chat, ...state];
  }

  void deleteChat(String chatId) {
    state = state.where((chat) => chat.id != chatId).toList();
  }

  void updateChat(Discussion discussion) {
    state = state.map((chat) {
      if (chat.id == discussion.id) {
        return discussion;
      }
      return chat;
    }).toList();
  }

  Future<void> refreshChats() async {
    // Resetting the fetch state for a fresh start
    _hasMore = true;
    _lastDocId = null;
    state = []; // Clear current state to reload notifications
    await fetchDiscussions();
  }
}

final discussionProvider =
    StateNotifierProvider.family<DiscussionNotifier, List<Discussion>, String>(
        (ref, query) {
  return DiscussionNotifier(query);
});

Future<String> sendDiscussion(Map<String, dynamic> map) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var url = dotenv.env['BASE_API_URL'];
  final response = await http.post(
    Uri.parse("$url/clubs/${map['channel']}/discussions"),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: json.encode(map),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['_id'];
  } else {
    throw Exception('Failed to send chat');
  }
}

Future<void> deleteDiscussionApi(
    BuildContext context, Map<String, dynamic> map) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var url = dotenv.env['BASE_API_URL'];
  final response = await http.delete(
    Uri.parse("$url/clubs/${map['channel']}/discussions/${map['id']}"),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    print(data);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: something went wrong')),
    );
  }
}

Future<void> markReadChats(channelId) async {
  var url = '${dotenv.env['BASE_API_URL']}/clubs/$channelId/discussions';
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');

  final response = await http.put(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    log('data: $jsonResponse');
  } else {
    throw Exception('Failed to load chatCount');
  }
}

Future<Discussion> castVoteInPoll(Map<String, dynamic> map) async {
  var url =
      '${dotenv.env['BASE_API_URL']}/clubs/${map['channel']}/vote/${map['_id']}';
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');

  final response = await http.put(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: json.encode(map),
  );

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    log('data: $jsonResponse');
    return Discussion.fromJson(jsonResponse);
  } else {
    throw Exception('Failed to load chatCount');
  }
}
