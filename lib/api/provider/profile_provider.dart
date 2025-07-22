import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:learningx_flutter_app/api/model/post_model.dart';
import 'package:learningx_flutter_app/api/model/profile_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileNotifier extends StateNotifier<Profile?> {
  final String id;
  ProfileNotifier(this.id)
      : super(Profile(
            id: id,
            user: PostUser(
                id: "id",
                firstname: "firstname",
                lastname: "lastname",
                displayName: "displayName",
                userImg:
                    "https://learningx-s3.s3.ap-south-1.amazonaws.com/user.png",
                userName: "userName",
                googleId: "googleId",
                verified: false),
            email: "email",
            gender: "",
            birthday: "",
            bio: "",
            currentLocation: "",
            website: "",
            blockedUser: [],
            createdAt: DateTime.now().toString())) {
    fetchProfile(id);
  }

  bool _isFetching = false;
  bool get isLoading => _isFetching;

  Future<void> fetchProfile(String id) async {
    _isFetching = true;
    var url = '${dotenv.env['BASE_API_URL']}/profile/$id';
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
      state = Profile.fromJson(jsonResponse);
    } else if (response.statusCode == 404) {
      var jsonResponse = json.decode(response.body);
      print(jsonResponse);
      state = null;
    } else {
      print(response.statusCode);
      throw Exception('Failed to load Profiles');
    }
    _isFetching = false;
  }

  Future<void> updateProfileApi(
      BuildContext context, Map<String, dynamic> data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var url = dotenv.env['BASE_API_URL'];
    final response = await http.put(
      Uri.parse("$url/profile/${data['_id']}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      final newProfile = Profile.fromJson(jsonResponse);

      // Find the existing Profile and update it
      state = newProfile;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Something went wrong!'),
      ));
      throw Exception('Failed to update Profile');
    }
  }

  Future<void> updateUserApi(
      BuildContext context, Map<String, dynamic> data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var url = dotenv.env['BASE_API_URL'];
    final response = await http.put(
      Uri.parse("$url/users/update/${data['_id']}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      final userJson = json.decode(response.body);
      PostUser user = PostUser.fromJson(userJson);
      state = state?.copyWith(user: user);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userImg', user.userImg);
      await prefs.setString('firstname', user.firstname);
      await prefs.setString('lastname', user.lastname);
      await prefs.setString('displayName', user.displayName);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated!")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: something went wrong')),
      );
    }
  }
}

final profileProvider =
    StateNotifierProvider.family<ProfileNotifier, Profile?, String>((ref, id) {
  return ProfileNotifier(id);
});

final currentProfileProvider = FutureProvider<Profile>((ref) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var userId = prefs.getString('id');
  var url = '${dotenv.env['BASE_API_URL']}/profile/$userId';

  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    return Profile.fromJson(jsonResponse);
  } else {
    throw Exception('Failed to load current profile');
  }
});

Future<void> updateProfileApi(
    BuildContext context, Map<String, dynamic> data) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var url = dotenv.env['BASE_API_URL'];
  final response = await http.put(
    Uri.parse("$url/profile/${data['_id']}"),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: json.encode(data),
  );

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    print(jsonResponse);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Updated!'),
    ));
  } else {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Something went wrong!'),
    ));
    throw Exception('Failed to update Profile');
  }
}
