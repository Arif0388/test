import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:learningx_flutter_app/api/model/post_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:learningx_flutter_app/api/provider/club_feed_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostNotifier extends StateNotifier<List<Post>> {
  final String filter;
  PostNotifier(this.ref, this.filter) : super([]) {
    fetchPosts();
  }
  final Ref ref;
  bool _isFetching = false;
  bool _hasMore = true;
  // ignore: avoid_init_to_null
  var _lastDocId = null;

  bool get isLoading => _isFetching;

  Future<void> fetchPosts() async {
    final clubItems = ref.watch(yourClubFeedProvider);
    List<String> clubs = [];
    clubs = clubItems.map((club) => club.id).toList();

    if (_isFetching || !_hasMore) return;

    _isFetching = true;
    var url = '${dotenv.env['BASE_API_URL']}/posts/fetch';
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'filter': filter,
        'clubs': clubs,
        'lastDocId': _lastDocId,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List jsonPosts = data['posts'];
      bool morePosts = data['morePosts'];
      _lastDocId = data['lastDocId'];

      final newPosts = jsonPosts.map((post) => Post.fromJson(post)).toList();
      state = [...state, ...newPosts];
      _hasMore = morePosts;
    } else {
      throw Exception('Failed to load posts');
    }

    _isFetching = false;
  }

  Future<void> refreshPosts() async {
    // Resetting the fetch state for a fresh start
    _hasMore = true;
    _lastDocId = null;
    state = []; // Clear current state to reload
    await fetchPosts();
  }

  void deletePost(String postId) {
    state = state.where((post) => post.id != postId).toList();
  }
}

final postProvider =
    StateNotifierProvider.family<PostNotifier, List<Post>, String>(
        (ref, filter) {
  return PostNotifier(ref, filter);
});

void createPostApi(BuildContext context, Map<String, dynamic> data) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var url = dotenv.env['BASE_API_URL'];
  final response = await http.post(
    Uri.parse("$url/posts"),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: json.encode(data),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    print(data);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Post added!")),
    );
    Navigator.pop(context);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: something went wrong')),
    );
  }
}

void updatePostApi(BuildContext context, Map<String, dynamic> data) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var url = dotenv.env['BASE_API_URL'];
  final response = await http.put(
    Uri.parse("$url/posts/${data['_id']}"),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: json.encode(data),
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

void updatePostContentApi(
    BuildContext context, Map<String, dynamic> data) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var url = dotenv.env['BASE_API_URL'];
  final response = await http.put(
    Uri.parse("$url/posts/${data['_id']}/info"),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: json.encode(data),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    print(data);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Post updated!")),
    );
    Navigator.pop(context);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: something went wrong')),
    );
  }
}

Future<void> deletePostApi(BuildContext context, String id) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var url = dotenv.env['BASE_API_URL'];
  final response = await http.delete(
    Uri.parse("$url/posts/$id"),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    print(data);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Post deleted!")),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: something went wrong')),
    );
  }
}
