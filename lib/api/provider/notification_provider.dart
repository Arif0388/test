import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:learningx_flutter_app/api/model/notification_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationNotifier extends StateNotifier<List<NotificationModel>> {
  NotificationNotifier() : super([]) {
    fetchNotifications();
  }
  bool _isFetching = false;
  bool _hasMore = true;
  // ignore: avoid_init_to_null, unused_field
  var _lastDocId = null;

  bool get isLoading => _isFetching;

  Future<void> fetchNotifications() async {
    if (_isFetching || !_hasMore) return;

    _isFetching = true;
    var url = '${dotenv.env['BASE_API_URL']}/notifications';
    if (_lastDocId != null) {
      url = '${dotenv.env['BASE_API_URL']}/notifications?_id[\$lt]=$_lastDocId';
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
      List jsonNotifications = data['notifications'];
      bool moreNotifications = data['moreNotifications'];
      _lastDocId = data['lastDocId'];

      final newNotifications = jsonNotifications
          .map((notification) => NotificationModel.fromJson(notification))
          .toList();
      state = [...state, ...newNotifications];
      _hasMore = moreNotifications;
    } else {
      throw Exception('Failed to load notifications');
    }

    _isFetching = false;
  }

  Future<void> refreshNotifications() async {
    // Resetting the fetch state for a fresh start
    _hasMore = true;
    _lastDocId = null;
    state = []; // Clear current state to reload notifications
    await fetchNotifications();
  }

  void removeNotification(String id) {
    state = state.where((item) => item.id != id).toList();
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, List<NotificationModel>>((ref) {
  return NotificationNotifier();
});

Future<void> deleteNotificationApi(BuildContext context, String id) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var url = dotenv.env['BASE_API_URL'];
  final response = await http.delete(
    Uri.parse("$url/notifications/$id"),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    print(data);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("notification removed!")),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: something went wrong')),
    );
  }
}

Future<void> markReadNotificationApi() async {
  var url = '${dotenv.env['BASE_API_URL']}/notifications';
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
    throw Exception('Failed to marked as read');
  }
}

Future<int> countUnreadNotificationApi() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var url = dotenv.env['BASE_API_URL'];
  final response = await http.get(
    Uri.parse("$url/notifications/count"),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    return jsonResponse['count'];
  } else {
    throw Exception('Failed to load count');
  }
}
