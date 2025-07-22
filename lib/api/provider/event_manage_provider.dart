import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:learningx_flutter_app/api/model/college_model.dart';
import 'package:learningx_flutter_app/api/model/event_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:learningx_flutter_app/api/model/event_team_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventManageNotifier extends StateNotifier<Event> {
  final String id;
  EventManageNotifier(this.id)
      : super(Event(
          id: id,
          eventTitle: "eventTitle",
          eventImg:
              "https://learningx-s3.s3.ap-south-1.amazonaws.com/image_850_315.png",
          admin: [],
          eventType: "entertainment",
          eventStartDate: DateTime.now().toString(),
          eventEndDate: DateTime.now().toString(),
          location: "offline",
          city: City(address: ""),
          venue: City(address: ""),
          eventLink: "",
          views: 0,
          visibility: "visibility",
          takeRegistration: false,
          registrationPlace: "registrationPlace",
          registrationLink: "registrationLink",
          participation: "participation",
          registrationStartDate: DateTime.now().toString(),
          registrationEndDate: DateTime.now().toString(),
          minSizeTeam: 1,
          maxSizeTeam: 1,
          registrationCharge: "registrationCharge",
          payment: "payment",
          registrationFee: 0,
          description: "description",
          guidelines: [],
          results: [],
          rewards: [],
          stages: [],
          partCertificate: false,
          totalRewards: "totalRewards",
          stepsDone: 6,
          verified: false,
          createdAt: DateTime.now().toString(),
        )) {
    fetchSelectedEvent(id);
  }

  bool _isFetching = false;
  bool get isLoading => _isFetching;

  Future<void> fetchSelectedEvent(String id) async {
    _isFetching = true;
    var url = '${dotenv.env['BASE_API_URL']}/events/$id';
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
      state = Event.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load Clubs');
    }
    _isFetching = false;
  }

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
      var jsonResponse = json.decode(response.body);
      final updatedEvent = Event.fromJson(jsonResponse);

      // Find the existing Club and update it
      state = updatedEvent;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Something went wrong!'),
      ));
      throw Exception('Failed to update Club');
    }
  }
}

final eventManageProvider =
    StateNotifierProvider.family<EventManageNotifier, Event, String>((ref, id) {
  return EventManageNotifier(id);
});

Future<Event> createEventApi(
    BuildContext context, Map<String, dynamic> data) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var url = dotenv.env['BASE_API_URL'];
  final response = await http.post(
    Uri.parse("$url/events"),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: json.encode(data),
  );

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    final createdEvent = Event.fromJson(jsonResponse);
    return createdEvent;
  } else {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Something went wrong!'),
    ));
    throw Exception('Failed to update Club');
  }
}

final fetchEventManageTeams =
    FutureProvider.family<List<EventTeam>, String>((ref, eventId) async {
  var url = '${dotenv.env['BASE_API_URL']}/events/$eventId/teams';
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
    throw Exception('Failed to load teams');
  }
});

Future<void> updateRegisteredTeamApi(
    BuildContext context, Map<String, dynamic> data) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var url = dotenv.env['BASE_API_URL'];
  final response = await http.put(
    Uri.parse("$url/events/${data['event']}/teams/${data['_id']}"),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: json.encode(data),
  );

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    print(jsonResponse);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Something went wrong!'),
    ));
    throw Exception('Failed to update Club');
  }
}
