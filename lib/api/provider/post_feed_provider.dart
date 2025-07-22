import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:learningx_flutter_app/api/model/post_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostFeedNotifier extends StateNotifier<List<Post>> {
  // final List<String> clubs;
  PostFeedNotifier() : super([]) {
    fetchPosts();
  }
  bool _isFetching = false;
  bool _hasMore = true;
  List<String> _lastFetchedIds = [];

  bool get isLoading => _isFetching;

  Future<void> fetchPosts() async {
    if (_isFetching || !_hasMore) return;

    _isFetching = true;
    var url = '${dotenv.env['BASE_API_URL']}/post/feed';
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'clubs': [],
        'lastFetchedIds': _lastFetchedIds,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List jsonPosts = data['posts'];
      bool morePosts = data['morePosts'];
      _lastFetchedIds.addAll(List<String>.from(data['lastFetchedIds']));

      final newPosts = jsonPosts.map((post) => Post.fromJson(post)).toList();
      state = [...state, ...newPosts];
      _hasMore = morePosts;
    } else {
      throw Exception('Failed to load posts');
    }

    _isFetching = false;
  }

  Future<void> addPost(BuildContext context, Map<String, dynamic> data) async {
    var url = '${dotenv.env['BASE_API_URL']}/posts';
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      final newPost = Post.fromJson(json.decode(response.body));
      state = [newPost, ...state];
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post added!")),
      );
      Navigator.pop(context);
    } else {
      throw Exception('Failed to add post');
    }
  }

  Future<void> refreshPostFeed() async {
    // Resetting the fetch state for a fresh start
    _hasMore = true;
    _lastFetchedIds = [];
    state = []; // Clear current state to reload
    await fetchPosts();
  }

  void deletePost(String postId) {
    state = state.where((post) => post.id != postId).toList();
  }
}

final postFeedProvider =
    StateNotifierProvider<PostFeedNotifier, List<Post>>((ref) {
  return PostFeedNotifier();
});
