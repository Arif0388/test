import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:learningx_flutter_app/api/model/member_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClubMemberNotifier extends StateNotifier<List<Member>> {
  final String query;
  ClubMemberNotifier(this.query) : super([]) {
    fetchMembers(query);
  }

  bool _isFetching = false;
  bool get isLoading => _isFetching;

  Future<void> fetchMembers(String query) async {
    _isFetching = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var url = '${dotenv.env['BASE_API_URL']}/clubs/$query';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      state = jsonResponse.map((item) => Member.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load Members');
    }
    _isFetching = false;
  }

  void removeMember(String memberId) {
    state = state.where((member) => member.id != memberId).toList();
  }
}

final clubMemberProvider =
    StateNotifierProvider.family<ClubMemberNotifier, List<Member>, String>(
        (ref, query) {
  return ClubMemberNotifier(query);
});

Future<void> requestToJoinClubApi(
    BuildContext context, Map<String, dynamic> data) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var url = dotenv.env['BASE_API_URL'];
  final response = await http.post(
    Uri.parse("$url/clubs/${data['club']}/members"),
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
      const SnackBar(content: Text("Request send!")),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: something went wrong')),
    );
  }
}

final fetchSingleMemberProvider =
    FutureProvider.family<List<Member>, Map<String, dynamic>>((ref, map) async {
  var url =
      '${dotenv.env['BASE_API_URL']}/clubs/${map['id']}/members/${map['user']}';
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
    return jsonResponse.map((item) => Member.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load member');
  }
});

Future<void> updateClubMemberApi(
    BuildContext context, Map<String, dynamic> data) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var url = dotenv.env['BASE_API_URL'];
  final response = await http.put(
    Uri.parse("$url/clubs/${data['club']}/members/${data['_id']}"),
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
      const SnackBar(content: Text("Member updated!")),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: something went wrong')),
    );
  }
}

Future<void> deleteClubMemberApi(
    BuildContext context, Map<String, dynamic> data) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var url = dotenv.env['BASE_API_URL'];
  final response = await http.delete(
      Uri.parse("$url/clubs/${data['club']}/members/${data['user']}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    print(data);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("member removed!")),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: something went wrong')),
    );
  }
}
