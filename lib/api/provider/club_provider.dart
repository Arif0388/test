import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:learningx_flutter_app/api/model/club_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

final clubProvider =
    FutureProvider.family<List<ClubItem>, String>((ref, query) async {
  var url = '${dotenv.env['BASE_API_URL']}/clubs$query';

  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((club) => ClubItem.fromJson(club)).toList();
  } else {
    throw Exception('Failed to load clubs');
  }
});

class ClubNotifier extends StateNotifier<Club> {
  final String id;
  ClubNotifier(this.id)
      : super(Club(
          id: id,
          admin: [],
          clubName: "Loading...",
          clubImg:
              "https://learningx-s3.s3.ap-south-1.amazonaws.com/CvW3AqVxR-image.png",
          category: "",
          councilName: "",
          channels: [],
          learningXClub: false,
          privacy: "private",
          collegeStatus: "rejected",
          description: "",
          email: "",
          website: "",
          instagram: "",
          linkedIn: "",
          learnings: [],
          members: [],
          faqs: [],
          createdAt: DateTime.now().toString(),
        ));

  bool _isFetching = false;
  bool get isLoading => _isFetching;

  Future<void> fetchClub(String id) async {
    try {
      _isFetching = true;
      var url = '${dotenv.env['BASE_API_URL']}/clubs/$id';
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
        state = Club.fromJson(jsonResponse);
      } else {
        throw Exception(response.statusCode == 404
            ? 'Club not found'
            : 'Failed to load Club: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString());
    } finally {
      _isFetching = false;
    }
  }

  Future<void> updateClubApi(
      BuildContext context, Map<String, dynamic> data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var url = dotenv.env['BASE_API_URL'];
    final response = await http.put(
      Uri.parse("$url/clubs/${data['_id']}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      final newClub = Club.fromJson(jsonResponse);

      // Find the existing Club and update it
      state = newClub;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Something went wrong!'),
      ));
      throw Exception('Failed to update Club');
    }
  }
}

final selectedClubProvider =
    StateNotifierProvider.family<ClubNotifier, Club, String>((ref, id) {
  return ClubNotifier(id);
});

Future<ClubItem> createClubApi(
    BuildContext context, Map<String, dynamic> data) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var url = dotenv.env['BASE_API_URL'];
  final response = await http.post(
    Uri.parse("$url/clubs"),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: json.encode(data),
  );

  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Club created successfully!")),
    );
    final jsonRes = json.decode(response.body);
    return ClubItem.fromJson(jsonRes);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: something went wrong')),
    );
    throw Exception('Failed to create club');
  }
}

Future<Club?> updateClubApi(
    BuildContext context, Map<String, dynamic> map) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var url = dotenv.env['BASE_API_URL'];
  final response = await http.put(
    Uri.parse("$url/clubs/${map['_id']}"),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: json.encode(map),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    Club clubItem = Club.fromJson(data);
    return clubItem;
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: something went wrong')),
    );
    return null;
  }
}

Future<void> deleteClubApi(BuildContext context, String id) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var url = dotenv.env['BASE_API_URL'];
  final response = await http.delete(
    Uri.parse("$url/clubs/$id"),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    print(data);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Club deleted!")),
    );
    Navigator.pop(context);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: something went wrong')),
    );
  }
}
