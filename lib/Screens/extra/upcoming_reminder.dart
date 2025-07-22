import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:learningx_flutter_app/Screens/event/event_fragment_page.dart';
import 'package:learningx_flutter_app/Screens/extra/upcoming_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpcomingReminderScreen extends StatefulWidget {
  const UpcomingReminderScreen({super.key});

  @override
  State<UpcomingReminderScreen> createState() => _UpcomingReminderState();
}

class _UpcomingReminderState extends State<UpcomingReminderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _currentUserId = "";

  @override
  void initState() {
    _loadCurrentUser();
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString("id") ?? "";
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateTime currentDateTime = DateTime.now();
    DateFormat formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
    String isoDateTime = formatter.format(currentDateTime);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Reminder'),
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Upcoming Sessions'),
              Tab(text: 'Registered Events'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                const UpcomingSessionScreen(),
                EventFragmentPage(
                  query:
                      "?stepsDone=6&registrationEndDate[\$gte]=$isoDateTime&\$or[0][registerdTeamLead]=$_currentUserId&\$or[1][admin]=$_currentUserId",
                  page: const Divider(
                    color: Colors.black87,
                    height: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
