import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/api/model/session_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class SessionNotifier extends StateNotifier<List<Session>> {
  final String query;
  SessionNotifier(this.query) : super([]) {
    fetchSessions(query);
  }

  bool _isFetching = false;
  bool get isLoading => _isFetching;

  Future<void> fetchSessions(String query) async {
    _isFetching = true;
    var url = '${dotenv.env['BASE_API_URL']}/clubs/$query';
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
      state = jsonResponse.map((session) => Session.fromJson(session)).toList();
    } else {
      throw Exception('Failed to load sessions');
    }
    _isFetching = false;
  }

  Future<void> createSession(
      BuildContext context, Map<String, dynamic> data) async {
    var url = '${dotenv.env['BASE_API_URL']}/clubs/${data['channel']}/session';
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
      final newSession = Session.fromJson(jsonResponse);
      state = [...state, newSession];
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Something went wrong!'),
      ));
      throw Exception('Failed to create session');
    }
  }

  Future<void> updateSession(
      BuildContext context, Map<String, dynamic> data) async {
    var url =
        '${dotenv.env['BASE_API_URL']}/clubs/${data['channel']}/session/${data['_id']}';
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
      final newSession = Session.fromJson(jsonResponse);

      // Find the existing session and update it
      state = state.map((session) {
        if (session.id == newSession.id) {
          return newSession;
        }
        return session;
      }).toList();

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Something went wrong!'),
      ));
      throw Exception('Failed to update session');
    }
  }

  Future<void> deleteSessionApi(
      BuildContext context, Map<String, String> data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var url = dotenv.env['BASE_API_URL'];
    final response = await http.delete(
      Uri.parse("$url/clubs/${data['channel']}/session/${data['_id']}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final js = json.decode(response.body);
      print(js);
      state = state.where((session) => session.id != data['_id']).toList();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Session deleted!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: something went wrong')),
      );
    }
  }
}

final sessionProvider =
    StateNotifierProvider.family<SessionNotifier, List<Session>, String>(
        (ref, query) {
  return SessionNotifier(query);
});

Future<List<Session>> fetchSessions(String query) async {
  var url = '${dotenv.env['BASE_API_URL']}/clubs/$query';
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
    return jsonResponse.map((session) => Session.fromJson(session)).toList();
  } else {
    throw Exception('Failed to load sessions');
  }
}
