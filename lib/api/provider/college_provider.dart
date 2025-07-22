import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:learningx_flutter_app/api/model/college_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

final collegeProvider =
    FutureProvider.family<List<College>, String>((ref, query) async {
  var url = '${dotenv.env['BASE_API_URL']}/college$query';

  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((college) => College.fromJson(college)).toList();
  } else {
    throw Exception('Failed to load colleges');
  }
});

class CollegeNotifier extends StateNotifier<College> {
  final String id;
  CollegeNotifier(this.id)
      : super(College(
            id: id,
            admin: [],
            collegeName: "Loading...",
            collegeImg:
                "https://learningx-s3.s3.ap-south-1.amazonaws.com/image_2_1.png",
            description: "",
            email: "email",
            website: "",
            instagram: "",
            linkedIn: "",
            restricted: false,
            emailDomain: "",
            verified: true,
            city: City(address: "")));

  bool _isFetching = false;
  bool get isLoading => _isFetching;

  Future<void> fetchCollege(String id) async {
    try {
      _isFetching = true;
      var url = '${dotenv.env['BASE_API_URL']}/college/$id';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        state = College.fromJson(jsonResponse);
      } else {
        throw Exception(response.statusCode == 404
            ? 'Campus not found'
            : 'Failed to load Campus: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString());
    } finally {
      _isFetching = false;
    }
  }

  Future<void> updateCollegeApi(
      BuildContext context, Map<String, dynamic> data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var url = dotenv.env['BASE_API_URL'];
    final response = await http.put(
      Uri.parse("$url/college/${data['_id']}"),
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
      final newCollege = College.fromJson(jsonResponse);

      // Find the existing College and update it
      state = newCollege;
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Something went wrong!'),
      ));
      throw Exception('Failed to update College');
    }
  }
}

final selectedCollegeProvider =
    StateNotifierProvider.family<CollegeNotifier, College, String>((ref, id) {
  return CollegeNotifier(id);
});

Future<College> createCollegeApi(
    BuildContext context, Map<String, dynamic> data) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var url = dotenv.env['BASE_API_URL'];
  final response = await http.post(
    Uri.parse("$url/college"),
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
      const SnackBar(content: Text("Campus form submitted!")),
    );
    Navigator.pop(context);
    return College.fromJson(data);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: something went wrong')),
    );
    throw "Error: something went wrong";
  }
}

Future<void> updateCollegeApi(
    BuildContext context, Map<String, dynamic> data) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var url = dotenv.env['BASE_API_URL'];
  final response = await http.put(
    Uri.parse("$url/college/${data['_id']}"),
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
      const SnackBar(content: Text("Page updated!")),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: something went wrong')),
    );
  }
}
