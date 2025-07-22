import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:learningx_flutter_app/api/model/community_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

final communityProvider =
    FutureProvider.family<List<CommunityItem>, String>((ref, query) async {
  var url = '${dotenv.env['BASE_API_URL']}/community$query';

  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse
        .map((community) => CommunityItem.fromJson(community))
        .toList();
  } else {
    throw Exception('Failed to load communitys');
  }
});

class CommunityNotifier extends StateNotifier<Community> {
  CommunityNotifier(String id)
      : super(Community(
            id: id,
            admin: [],
            title: '',
            coverImg:
                'https://learningx-s3.s3.ap-south-1.amazonaws.com/image_2_1.png',
            category: '',
            channels: [],
            privacy: '',
            description: '',
            email: '',
            website: '',
            instagram: '',
            linkedIn: '',
            learnings: [],
            members: [],
            createdAt: DateTime.now().toString()));

  bool _isFetching = false;
  bool get isLoading => _isFetching;

  // Fetch community details
  Future<void> fetchCommunity(String id) async {
    try {
      _isFetching = true;

      var url = '${dotenv.env['BASE_API_URL']}/community/$id';
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
        var jsonResponse = json.decode(response.body);
        state = Community.fromJson(jsonResponse);
      } else {
        throw Exception(response.statusCode == 404
            ? 'Community not found'
            : 'Failed to load Community: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString());
    } finally {
      _isFetching = false;
    }
  }

  // Update community details
  Future<void> updateCommunityApi(
      BuildContext context, Map<String, dynamic> data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var url = dotenv.env['BASE_API_URL'];
    final response = await http.put(
      Uri.parse("$url/community/${data['_id']}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Updated successfully!')),
      );

      var jsonResponse = json.decode(response.body);
      final newCommunity = Community.fromJson(jsonResponse);

      // Update the community in state
      state = newCommunity;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong!')),
      );
      throw Exception('Failed to update Community');
    }
  }
}

final selectedCommunityProvider =
    StateNotifierProvider.family<CommunityNotifier, Community, String>(
        (ref, id) {
  return CommunityNotifier(id);
});

Future<void> createCommunityApi(
    BuildContext context, Map<String, dynamic> data) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var url = dotenv.env['BASE_API_URL'];
  final response = await http.post(
    Uri.parse("$url/community"),
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
      const SnackBar(content: Text("Community created!")),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: something went wrong')),
    );
  }
}

Future<void> updateCommunityApi(
    BuildContext context, Map<String, dynamic> data) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var url = dotenv.env['BASE_API_URL'];
  final response = await http.put(
    Uri.parse("$url/community/${data['_id']}"),
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
      const SnackBar(content: Text("Community updated!")),
    );
    Navigator.pop(context);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: something went wrong')),
    );
  }
}
