import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:learningx_flutter_app/api/model/channel_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChannelNotifier extends StateNotifier<List<ChannelWithClub>> {
  final String query;
  ChannelNotifier(this.query) : super([]) {
    fetchChannels(query);
  }

  bool _isFetching = false;
  bool get isLoading => _isFetching;

  Future<void> fetchChannels(String query) async {
    _isFetching = true;
    var url = '${dotenv.env['BASE_API_URL']}/channel?club=$query';
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
      state =
          jsonResponse.map((item) => ChannelWithClub.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load Channels');
    }
    _isFetching = false;
  }

  Future<void> createChannel(
      BuildContext context, Map<String, dynamic> data) async {
    var url = '${dotenv.env['BASE_API_URL']}/channel';
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Created successfully!'),
      ));
      var jsonResponse = json.decode(response.body);
      final newChannel = ChannelWithClub.fromJson(jsonResponse);
      state = [newChannel, ...state];
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Something went wrong!'),
      ));
      throw Exception('Failed to create Channel');
    }
  }

  Future<void> updateChannel(
      BuildContext context, Map<String, dynamic> data) async {
    var url = '${dotenv.env['BASE_API_URL']}/channel/${data['_id']}';
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Updated successfully!'),
      ));
      var jsonResponse = json.decode(response.body);
      final newChannel = ChannelWithClub.fromJson(jsonResponse);

      // Find the existing Channel and update it
      state = state.map((channel) {
        if (channel.id == newChannel.id) {
          return newChannel;
        }
        return channel;
      }).toList();

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Something went wrong!'),
      ));
      throw Exception('Failed to update Channel');
    }
  }

  Future<void> deleteChannelApi(BuildContext context, String id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var url = dotenv.env['BASE_API_URL'];
    final response = await http.delete(
      Uri.parse("$url/channel/$id"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);
      state = state.where((channel) => channel.id != id).toList();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('deleted!'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: something went wrong')),
      );
    }
  }
}

final channelProvider = StateNotifierProvider.family<ChannelNotifier,
    List<ChannelWithClub>, String>((ref, query) {
  return ChannelNotifier(query);
});

Future<void> deleteChannelApi(BuildContext context, String id) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var url = dotenv.env['BASE_API_URL'];
  final response = await http.delete(
    Uri.parse("$url/channel/$id"),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    print(data);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Channel deleted!")),
    );
    Navigator.pop(context);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: something went wrong')),
    );
  }
}

Future<Channel> fetchSingleChannelApi(String id) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var url = dotenv.env['BASE_API_URL'];

  final response = await http.get(Uri.parse("$url/channel/$id"), headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  });

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    return Channel.fromJson(jsonResponse);
  } else {
    throw Exception('Failed to load members');
  }
}
