import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:learningx_flutter_app/Screens/club/session/session_item.dart';
import 'package:learningx_flutter_app/api/model/session_model.dart';
import 'package:learningx_flutter_app/api/provider/club_feed_provider.dart';
import 'package:learningx_flutter_app/api/provider/session_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpcomingSessionScreen extends ConsumerStatefulWidget {
  const UpcomingSessionScreen({super.key});

  @override
  ConsumerState<UpcomingSessionScreen> createState() =>
      _UpcomingSessionScreenState();
}

class _UpcomingSessionScreenState extends ConsumerState<UpcomingSessionScreen> {
  var sessions = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString("id") ?? "";
    final yourClubs = ref.watch(yourClubFeedProvider);
    // Calculate the current ISO date time for filtering sessions
    DateTime currentDateTime = DateTime.now();
    DateFormat formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
    String isoDateTime = formatter.format(currentDateTime);
    // Gather sessions based on the user's club memberships
    for (int i = 0; i < yourClubs.length; i++) {
      for (int j = 0; j < yourClubs[i].channels.length; j++) {
        if (yourClubs[i].channels[j].members.contains(userId)) {
          final fetchedSessions = await fetchSessions(
              "${yourClubs[i].channels[j].id}/session?startTime[\$gte]=$isoDateTime");
          setState(() {
            sessions.addAll(fetchedSessions);
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: sessions.isEmpty
            ? const Text('No session available')
            : ListView.builder(
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  Session session = sessions[index];
                  return SessionItemWidget(
                    session: session,
                    isAdmin: false,
                  );
                },
              ),
      ),
    );
  }
}
