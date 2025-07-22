import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:learningx_flutter_app/api/model/files_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FilesNotifier extends StateNotifier<List<Files>> {
  final String channelId;
  FilesNotifier(this.channelId) : super([]) {
    fetchFiles();
  }
  bool _isFetching = false;
  bool _hasMore = true;
  // ignore: avoid_init_to_null, unused_field
  var _lastDocId = null;

  bool get isLoading => _isFetching;

  Future<void> fetchFiles() async {
    if (_isFetching || !_hasMore) return;

    _isFetching = true;
    var url = '${dotenv.env['BASE_API_URL']}/clubs/$channelId/files';
    if (_lastDocId != null) {
      url =
          '${dotenv.env['BASE_API_URL']}/clubs/$channelId/files?_id[\$lt]=$_lastDocId';
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
      List jsonFiles = data['files'];
      bool moreFiles = data['moreFiles'];
      _lastDocId = data['lastDocId'];

      final newFiles = jsonFiles.map((file) => Files.fromJson(file)).toList();
      state = [...state, ...newFiles];
      _hasMore = moreFiles;
    } else {
      throw Exception('Failed to load files');
    }

    _isFetching = false;
  }

  Future<void> addFile(BuildContext context, Map<String, dynamic> data) async {
    var url = '${dotenv.env['BASE_API_URL']}/clubs/${data['channel']}/files';
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
      final newFile = Files.fromJson(json.decode(response.body));
      state = [newFile, ...state];
    } else {
      throw Exception('Failed to add file');
    }
  }

  void deleteFile(String filesId) {
    state = state.where((file) => file.id != filesId).toList();
  }

  Future<void> refreshFiles() async {
    // Resetting the fetch state for a fresh start
    _hasMore = true;
    _lastDocId = null;
    state = []; // Clear current state to reload notifications
    await fetchFiles();
  }
}

final filesProvider =
    StateNotifierProvider.family<FilesNotifier, List<Files>, String>(
        (ref, channelId) {
  return FilesNotifier(channelId);
});

Future<void> deleteFileApi(
    BuildContext context, Map<String, dynamic> map) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var url = dotenv.env['BASE_API_URL'];
  final response = await http.delete(
    Uri.parse("$url/clubs/${map['channel']}/files/${map['id']}"),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    print(data);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("file deleted!")),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: something went wrong')),
    );
  }
}

Future<void> markReadFiles(channelId) async {
  var url = '${dotenv.env['BASE_API_URL']}/clubs/$channelId/files';
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
    throw Exception('Failed to load chatCount');
  }
}
