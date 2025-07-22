import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:learningx_flutter_app/api/model/club_model.dart';
import 'package:learningx_flutter_app/api/model/council_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:learningx_flutter_app/api/model/populated_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

final councilProvider =
    FutureProvider.family<List<CouncilItem>, String>((ref, query) async {
  var url = '${dotenv.env['BASE_API_URL']}/council$query';

  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse
        .map((council) => CouncilItem.fromJson(council))
        .toList();
  } else {
    throw Exception('Failed to load councils');
  }
});

class CouncilNotifier extends StateNotifier<Council> {
  CouncilNotifier(String id)
      : super(Council(
          id: id,
          admin: [],
          councilName: "Loading...",
          councilImg:
              "https://learningx-s3.s3.ap-south-1.amazonaws.com/image_2_1.png",
          college: PopulatedCollege(
            id: "id",
            collegeName: "",
            collegeImg:
                "https://learningx-s3.s3.ap-south-1.amazonaws.com/image_2_1.png",
            admin: [],
            email: "",
            restricted: true,
            emailDomain: "",
          ),
          clubItem: ClubItem(
              id: 'id',
              admin: [],
              clubName: '',
              clubImg:
                  "https://learningx-s3.s3.ap-south-1.amazonaws.com/image_2_1.png",
              category: "council",
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
              members: []),
          description: "",
          email: "",
          website: "",
          instagram: "",
          linkedIn: "",
          createdAt: DateTime.now().toString(),
        ));

  bool _isFetching = false;
  bool get isLoading => _isFetching;

  // Fetch council details
  Future<void> fetchCouncil(String id) async {
    try {
      _isFetching = true;

      var url = '${dotenv.env['BASE_API_URL']}/council/$id';
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
        state = Council.fromJson(jsonResponse);
      } else {
        throw Exception(response.statusCode == 404
            ? 'Council not found'
            : 'Failed to load Council: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString());
    } finally {
      _isFetching = false;
    }
  }

  // Update council details
  Future<void> updateCouncilApi(
      BuildContext context, Map<String, dynamic> data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var url = dotenv.env['BASE_API_URL'];
    final response = await http.put(
      Uri.parse("$url/council/${data['_id']}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Updated successfully!')),
      );

      var jsonResponse = json.decode(response.body);
      final newCouncil = Council.fromJson(jsonResponse);

      // Update the council in state
      state = newCouncil;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong!')),
      );
      throw Exception('Failed to update Council');
    }
  }
}

final selectedCouncilProvider =
    StateNotifierProvider.family<CouncilNotifier, Council, String>((ref, id) {
  return CouncilNotifier(id);
});

Future<void> createCouncilApi(
    BuildContext context, Map<String, dynamic> data) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var url = dotenv.env['BASE_API_URL'];
  final response = await http.post(
    Uri.parse("$url/council"),
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
      const SnackBar(content: Text("Council created!")),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: something went wrong')),
    );
  }
}

Future<void> updateCouncilApi(
    BuildContext context, Map<String, dynamic> data) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var url = dotenv.env['BASE_API_URL'];
  final response = await http.put(
    Uri.parse("$url/council/${data['_id']}"),
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
      const SnackBar(content: Text("Council updated!")),
    );
    Navigator.pop(context);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: something went wrong')),
    );
  }
}
