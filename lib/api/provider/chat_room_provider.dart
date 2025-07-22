import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:learningx_flutter_app/api/model/chat_room_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

final chatRoomProvider = FutureProvider<List<ChatRoom>>((ref) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var userId = prefs.getString('id');
  var url = '${dotenv.env['BASE_API_URL']}/chats/room?users=$userId';

  final response = await http.get(Uri.parse(url), headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  });

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((room) => ChatRoom.fromJson(room)).toList();
  } else {
    throw Exception('Failed to load chatRooms');
  }
});

Future<String> createChatRoomApi(
    BuildContext context, Map<String, dynamic> data) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var url = dotenv.env['BASE_API_URL'];
  final response = await http.post(
    Uri.parse("$url/chats/room"),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: json.encode(data),
  );

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    String room = jsonData['_id'];
    return room;
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: something went wrong')),
    );
    return "id";
  }
}

Future<void> updateChatRoomApi(
    BuildContext context, Map<String, dynamic> data) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var url = dotenv.env['BASE_API_URL'];
  final response = await http.put(
    Uri.parse("$url/chats/room/${data['_id']}"),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: json.encode(data),
  );

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    print(jsonData);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: something went wrong')),
    );
  }
}

Future<List<ChatRoom>> fetchSingleChatRoom(
    BuildContext context, List<String> users) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var url =
      '${dotenv.env['BASE_API_URL']}/chats/room?users[\$all]=${users[0]}&users[\$all]=${users[1]}';
  final response = await http.get(Uri.parse(url), headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  });

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    print(jsonResponse);
    return jsonResponse.map((room) => ChatRoom.fromJson(room)).toList();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: something went wrong')),
    );
    throw Exception('Failed to load chatRooms');
  }
}

void markReadChatsApi(BuildContext context, String roomId) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var url = dotenv.env['BASE_API_URL'];
  final response = await http.put(
    Uri.parse("$url/chats/$roomId"),
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

Future<int> countUnreadChatRoomApi() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var url = dotenv.env['BASE_API_URL'];
  final response = await http.get(
    Uri.parse("$url/chats/room/count"),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    return jsonResponse['count'];
  } else {
    throw Exception('Failed to load chatRooms');
  }
}
