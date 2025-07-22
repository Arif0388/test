import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:learningx_flutter_app/api/model/club_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

final yourClubFeedProvider =
    StateNotifierProvider<ClubFeedNotifier, List<ClubItem>>((ref) {
  return ClubFeedNotifier()..loadCachedClubs();
});

class ClubFeedNotifier extends StateNotifier<List<ClubItem>> {
  ClubFeedNotifier() : super([]);

  Future<void> loadCachedClubs() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedClubs = prefs.getStringList('cachedClubs');
    if (cachedClubs != null) {
      state = cachedClubs
          .map((clubJson) => ClubItem.fromJson(jsonDecode(clubJson)))
          .toList();
    }
  }

  Future<void> fetchClubItems() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var userId = prefs.getString('id');
    var url = '${dotenv.env['BASE_API_URL']}/club/feed?members=$userId';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      List<ClubItem> newClubs =
          jsonResponse.map((item) => ClubItem.fromJson(item)).toList();

      // Update the state
      state = newClubs;
      // Cache the new data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'cachedClubs',
        newClubs.map((club) => jsonEncode(club.toJson())).toList(),
      );
    } else {
      throw Exception('Failed to load ClubItems');
    }
  }

  void addClub(ClubItem club) {
    state = [club, ...state];
  }

  void deleteClub(String clubId) {
    state = state.where((club) => club.id != clubId).toList();
  }
}

final blueClubFeedProvider = FutureProvider<List<ClubItem>>((ref) async {
  var url = '${dotenv.env['BASE_API_URL']}/club/feed?learningXClub=true';
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
    return jsonResponse.map((club) => ClubItem.fromJson(club)).toList();
  } else {
    throw Exception('Failed to load clubs');
  }
});

Future<int> fetchUnreadChats(channelId) async {
  var url = '${dotenv.env['BASE_API_URL']}/clubs/$channelId/chatCount';
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
    return jsonResponse['count'];
  } else {
    throw Exception('Failed to load chatCount');
  }
}
