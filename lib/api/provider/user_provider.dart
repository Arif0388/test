import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:learningx_flutter_app/api/model/post_model.dart';
import 'package:learningx_flutter_app/api/model/user_modal.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

final userProvider =
    FutureProvider.family<List<User>, String>((ref, query) async {
  var url = '${dotenv.env['BASE_API_URL']}/users$query';
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
    return jsonResponse.map((user) => User.fromJson(user)).toList();
  } else {
    throw Exception('Failed to load users');
  }
});

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
    print(userJson);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated!")),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: something went wrong')),
    );
  }
}

Future<void> activateAccountApi(BuildContext context, String id) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String firstname = prefs.getString('firstname') ?? "";
  String lastname = prefs.getString('lastname') ?? "";
  var token = prefs.getString('token');
  var url = dotenv.env['BASE_API_URL'];
  final response = await http.put(
    Uri.parse("$url/users/activate/$id"),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body:
        json.encode({'_id': id, 'firstname': firstname, 'lastname': lastname}),
  );

  if (response.statusCode == 200) {
    final userJson = json.decode(response.body);
    print(userJson);
    PostUser user = PostUser.fromJson(userJson);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('displayName', user.displayName);
    await prefs.setBool('isLoggedIn', true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Account activated!")),
    );
    context.go("/home");
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: something went wrong')),
    );
  }
}
