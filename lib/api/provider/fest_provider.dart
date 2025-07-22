import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:learningx_flutter_app/api/model/fest_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:learningx_flutter_app/api/model/populated_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

final festProvider =
    FutureProvider.family<List<Fest>, String>((ref, query) async {
  var url = '${dotenv.env['BASE_API_URL']}/fests$query';

  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((fest) => Fest.fromJson(fest)).toList();
  } else {
    throw Exception('Failed to load fests');
  }
});

class FestNotifier extends StateNotifier<Fest> {
  FestNotifier(String id)
      : super(Fest(
          id: id,
          admin: [],
          festName: "Loading...",
          festImg:
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
          startDate: DateTime.now().toString(),
          endDate: DateTime.now().toString(),
          description: "",
          email: "",
          website: "",
          instagram: "",
          linkedIn: "",
        ));

  bool _isFetching = false;
  bool get isLoading => _isFetching;

  // Fetch fest details
  Future<void> fetchFest(String id) async {
    try {
      _isFetching = true;

      var url = '${dotenv.env['BASE_API_URL']}/fests/$id';
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
        state = Fest.fromJson(jsonResponse);
      } else {
        throw Exception(response.statusCode == 404
            ? 'Fest not found'
            : 'Failed to load Fest: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString());
    } finally {
      _isFetching = false;
    }
  }

  // Update fest details
  Future<void> updateFestApi(
      BuildContext context, Map<String, dynamic> data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var url = dotenv.env['BASE_API_URL'];
    final response = await http.put(
      Uri.parse("$url/fests/${data['_id']}"),
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
      final newFest = Fest.fromJson(jsonResponse);

      // Update the fest in state
      state = newFest;

      Navigator.pop(context); // Close the update form
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong!')),
      );
      throw Exception('Failed to update Fest');
    }
  }
}

final selectedFestProvider =
    StateNotifierProvider.family<FestNotifier, Fest, String>((ref, id) {
  return FestNotifier(id);
});

Future<void> createFestApi(
    BuildContext context, Map<String, dynamic> data) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var url = dotenv.env['BASE_API_URL'];
  final response = await http.post(
    Uri.parse("$url/fests"),
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
      const SnackBar(content: Text("Fest fest created!")),
    );
    Navigator.pop(context);
  } else {
    final data = json.decode(response.body);
    print(data);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: something went wrong')),
    );
  }
}

Future<void> updateFestApi(
    BuildContext context, Map<String, dynamic> data) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var url = dotenv.env['BASE_API_URL'];
  final response = await http.put(
    Uri.parse("$url/fests/${data['_id']}"),
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
      const SnackBar(content: Text("Fest updated!")),
    );
    Navigator.pop(context);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: something went wrong')),
    );
  }
}

Future<void> deleteFestApi(BuildContext context, String festId) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var url = dotenv.env['BASE_API_URL'];
  final response = await http.delete(
    Uri.parse("$url/fests/$festId"),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    print(data);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fest Deleted!')),
    );
    Navigator.pop(context);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: something went wrong')),
    );
  }
}