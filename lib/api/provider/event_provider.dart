import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:learningx_flutter_app/api/model/event_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:learningx_flutter_app/api/model/event_team_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventNotifier extends StateNotifier<List<EventItem>> {
  final String query;
  EventNotifier(this.query) : super([]) {
    fetchEvents();
  }
  bool _isFetching = false;
  bool _hasMore = true;
  // ignore: avoid_init_to_null, unused_field
  var _lastDocId = null;

  bool get isLoading => _isFetching;

  Future<void> fetchEvents() async {
    if (_isFetching || !_hasMore) return;

    _isFetching = true;
    var url = '${dotenv.env['BASE_API_URL']}/events$query';
    if (_lastDocId != null) {
      url = '${dotenv.env['BASE_API_URL']}/events$query&_id[\$lt]=$_lastDocId';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List jsonEvents = data['events'];
      bool moreEvents = data['moreEvents'];
      _lastDocId = data['lastDocId'];

      final newEvents =
          jsonEvents.map((event) => EventItem.fromJson(event)).toList();
      state = [...state, ...newEvents];
      _hasMore = moreEvents;
    } else {
      throw Exception('Failed to load events');
    }

    _isFetching = false;
  }

  Future<void> refreshEvent() async {
    // Resetting the fetch state for a fresh start
    _hasMore = true;
    _lastDocId = null;
    state = []; // Clear current state to reload
    await fetchEvents();
  }

  void removeEvent(String eventId) {
    state = state.where((event) => event.id != eventId).toList();
  }
}

final eventProvider =
    StateNotifierProvider.family<EventNotifier, List<EventItem>, String>(
        (ref, query) {
  return EventNotifier(query);
});

final selectedEventProvider =
    FutureProvider.family<Event, String>((ref, eventId) async {
  try {
    var url = '${dotenv.env['BASE_API_URL']}/events/$eventId';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      return Event.fromJson(jsonResponse);
    } else {
      throw (response.statusCode == 404
          ? 'Event not found'
          : 'Failed to load Event: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception(e.toString());
  }
});

Future<void> updateEventApi(
    BuildContext context, Map<String, dynamic> data) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var url = dotenv.env['BASE_API_URL'];
  final response = await http.put(
    Uri.parse("$url/events/${data['_id']}"),
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

Future<void> deleteEventApi(BuildContext context, String eventId) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var url = dotenv.env['BASE_API_URL'];
  final response = await http.delete(
    Uri.parse("$url/events/$eventId"),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    print(data);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event Deleted!')),
    );
    Navigator.pop(context);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: something went wrong')),
    );
  }
}

Future<EventTeam> registerEventApi(
    BuildContext context, Map<String, dynamic> data) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var url = dotenv.env['BASE_API_URL'];
  final response = await http.post(
    Uri.parse("$url/events/${data['event']}/teams"),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: json.encode(data),
  );

  if (response.statusCode == 200) {
    final jsonRes = json.decode(response.body);
    print(jsonRes);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Your form has been submitted.")),
    );
    Navigator.pop(context);
    return EventTeam.fromJson(jsonRes);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: something went wrong')),
    );
    throw "Error: something went wrong";
  }
}

final fetchRegisteredTeam =
    FutureProvider.family<List<EventTeam>, Map<String, dynamic>>(
        (ref, map) async {
  var url =
      '${dotenv.env['BASE_API_URL']}/events/${map['event']}/teams/${map['user']}';
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
    print(jsonResponse);
    return jsonResponse.map((team) => EventTeam.fromJson(team)).toList();
  } else {
    throw Exception('Failed to load college');
  }
});
