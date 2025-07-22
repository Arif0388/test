import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:learningx_flutter_app/api/model/comment_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostCommentNotifier extends StateNotifier<List<PostComment>> {
  final String postId;
  PostCommentNotifier(this.postId) : super([]) {
    fetchComments();
  }
  bool _isFetching = false;
  bool _hasMore = true;
  // ignore: unused_field, avoid_init_to_null
  var _lastDocId = null;

  bool get isLoading => _isFetching;

  Future<void> fetchComments() async {
    if (_isFetching || !_hasMore) return;

    _isFetching = true;
    var url = '${dotenv.env['BASE_API_URL']}/posts/$postId/comments';
    if (_lastDocId != null) {
      url =
          '${dotenv.env['BASE_API_URL']}/posts/$postId/comments?_id[\$lt]=$_lastDocId';
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
      List jsonComments = data['comments'];
      bool moreComments = data['moreComments'];
      _lastDocId = data['lastDocId'];

      final newComments =
          jsonComments.map((comment) => PostComment.fromJson(comment)).toList();
      state = [...state, ...newComments];
      _hasMore = moreComments;
    } else {
      throw Exception('Failed to load comments');
    }

    _isFetching = false;
  }

  Future<void> createPostCommentApi(
      BuildContext context, Map<String, dynamic> data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var url = dotenv.env['BASE_API_URL'];
    final response = await http.post(
      Uri.parse("$url/posts/${data['post']}/comments"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      final newComment = PostComment.fromJson(json.decode(response.body));
      state = [newComment, ...state];
    } else {
      throw Exception('Failed to add comment');
    }
  }

  Future<void> deletePostCommentApi(
      BuildContext context, Map<String, dynamic> map) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var url = dotenv.env['BASE_API_URL'];
    final response = await http.delete(
      Uri.parse("$url/posts/${map['post']}/comments/${map['_id']}"),
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

final postCommentProvider = StateNotifierProvider.family<PostCommentNotifier,
    List<PostComment>, String>((ref, postId) {
  return PostCommentNotifier(postId);
});
