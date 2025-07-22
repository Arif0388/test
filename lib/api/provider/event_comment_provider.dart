import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:learningx_flutter_app/api/model/event_comment_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventCommentNotifier extends StateNotifier<List<EventComment>> {
  final Map<String, String> map;
  EventCommentNotifier(this.map) : super([]) {
    fetchEventComments(map);
  }

  bool _isFetching = false;
  bool get isLoading => _isFetching;

  Future<void> fetchEventComments(Map<String, String> map) async {
    _isFetching = true;
    var url =
        '${dotenv.env['BASE_API_URL']}/events/${map['eventId']}/comments?parentCommentId=${map['parentCommentId']}';
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
      List jsonResponse = json.decode(response.body);
      state = jsonResponse
          .map((comment) => EventComment.fromJson(comment))
          .toList();
    } else {
      throw Exception('Failed to load EventComments');
    }
    _isFetching = false;
  }

  Future<void> createEventComment(
      BuildContext context, Map<String, dynamic> data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var url = dotenv.env['BASE_API_URL'];
    final response = await http.post(
      Uri.parse("$url/events/${data['event']}/comments"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("comment added!"),
      ));
      var jsonResponse = json.decode(response.body);
      final newEventComment = EventComment.fromJson(jsonResponse);
      state = [newEventComment, ...state];
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Something went wrong!'),
      ));
      throw Exception('Failed to create EventComment');
    }
  }

  Future<void> deleteEventCommentApi(
      BuildContext context, Map<String, dynamic> map) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var url = dotenv.env['BASE_API_URL'];
    final response = await http.delete(
      Uri.parse("$url/events/${map['event']}/comments/${map['_id']}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);
      state = state.where((comment) => comment.id != map['_id']).toList();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("comment deleted!")),
      );
    } else {
      throw Exception('Failed to delete comment');
    }
  }
}

final eventCommentProvider = StateNotifierProvider.family<EventCommentNotifier,
    List<EventComment>, Map<String, String>>((ref, map) {
  return EventCommentNotifier(map);
});
