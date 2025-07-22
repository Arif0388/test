import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:learningx_flutter_app/api/model/club_model.dart';
import 'package:learningx_flutter_app/api/model/event_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventFeedNotifier extends StateNotifier<List<EventItem>> {
  final String collegeId;
  EventFeedNotifier(this.collegeId) : super([]);

  bool _isFetching = false;
  bool _hasMore = true;
  List<String> _lastFetchedIds = [];
  List<String> userClubIds = [];

  bool get isLoading => _isFetching;

  Future<void> fetchEvents() async {
    if (_isFetching || !_hasMore) return;

    final prefs = await SharedPreferences.getInstance();
    final cachedClubs = prefs.getStringList('cachedClubs');
    final isCollegeAdmin = prefs.getBool("isCollegeAdmin");
    if (cachedClubs != null) {
      final ids = cachedClubs
          .map((clubJson) => ClubItem.fromJson(jsonDecode(clubJson)).id)
          .toList();
      userClubIds = ids;
    }

    _isFetching = true;
    var url = '${dotenv.env['BASE_API_URL']}/event/feed';
    var token = prefs.getString('token');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'lastFetchedIds': _lastFetchedIds,
        'collegeId': collegeId,
        'userClubIds': userClubIds,
        'isCollegeAdmin': isCollegeAdmin
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List jsonEvents = data['events'];
      bool moreEvents = data['moreEvents'];
      _lastFetchedIds.addAll(List<String>.from(data['lastFetchedIds']));

      final newEvents =
          jsonEvents.map((event) => EventItem.fromJson(event)).toList();
      state = [...state, ...newEvents];
      _hasMore = moreEvents;
    } else {
      throw Exception('Failed to load events');
    }

    _isFetching = false;
  }

  Future<void> refreshEventFeed() async {
    // Resetting the fetch state for a fresh start
    _hasMore = true;
    _lastFetchedIds = [];
    state = []; // Clear current state to reload
    await fetchEvents();
  }

  void removeEvent(String eventId) {
    state = state.where((event) => event.id != eventId).toList();
  }

  void addEvent(EventItem eventItem) {
    state = [eventItem, ...state];
  }

  void updateEvent(EventItem eventItem) {
    state = state.map((existingEvent) {
      if (existingEvent.id == eventItem.id) {
        return eventItem; // Replace the event with the updated one
      }
      return existingEvent; // Keep the existing event as is
    }).toList();
  }
}

final eventFeedProvider =
    StateNotifierProvider.family<EventFeedNotifier, List<EventItem>, String>(
        (ref, collegeId) {
  return EventFeedNotifier(collegeId);
});
