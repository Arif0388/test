import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/fest/fest_fragment_page.dart';
import 'package:learningx_flutter_app/Screens/home/empty_college_selected.dart';
import 'package:learningx_flutter_app/Screens/home/event_feed.dart';
import 'package:learningx_flutter_app/api/provider/college_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventTabFeed extends ConsumerStatefulWidget {
  final String id;
  const EventTabFeed({super.key, required this.id});

  @override
  ConsumerState<EventTabFeed> createState() => _EventTabFeedState();
}

class _EventTabFeedState extends ConsumerState<EventTabFeed> {
  String _collegeId = "";
  String _currentUserId = "";
  bool isAdmin = false;
  var privacy = "private";

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadCurrentUser();
  }

  _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _collegeId = prefs.getString('college') ?? "";
      _currentUserId = prefs.getString("id") ?? "";
    });
  }

  void setCollegeAdmin(isCollegeAdmin) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isCollegeAdmin', isCollegeAdmin);
  }

  void onPrivacyRadioClicked(String? value) {
    setState(() {
      privacy = value ?? "private";
    });
  }

  @override
  Widget build(BuildContext context) {
    final collegeData = ref.watch(selectedCollegeProvider(widget.id));

    setState(() {
      isAdmin = collegeData.admin.any((item) => item.id == _currentUserId);
      setCollegeAdmin(isAdmin);
    });

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 211, 232, 255),
            title: const Row(
              children: [
                TabBar(
                  labelColor: Color.fromARGB(255, 56, 114, 220),
                  unselectedLabelColor: Colors.black,
                  indicatorColor: Color.fromARGB(255, 56, 114, 220),
                  dividerColor: Color.fromARGB(255, 211, 232, 255),
                  tabAlignment: TabAlignment.start,
                  isScrollable: true,
                  tabs: [
                    Tab(text: 'Events'),
                    Tab(text: 'Fest'),
                  ],
                ),
                // const Spacer(),
                // const Text(
                //   'My Campus only',
                //   style: TextStyle(
                //     color: Colors.black,
                //     fontSize: 12,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                // const SizedBox(
                //   width: 8,
                // ),
                // Transform.scale(
                //   scale: 0.75, // Adjust scale factor as needed
                //   child: Switch(
                //     value: privacy == "public",
                //     onChanged: (value) {
                //       onPrivacyRadioClicked(value ? "public" : "private");
                //     },
                //     activeColor: const Color.fromARGB(255, 56, 114, 220),
                //     inactiveThumbColor: Colors.grey,
                //     inactiveTrackColor: Colors.grey[700],
                //   ),
                // )
              ],
            )),
        body: TabBarView(
          children: [
            const EventsScreen(),
            (_collegeId != "" && _collegeId != dotenv.env['OTHER_COLLEGE_ID'])
                ? FestFragmentPage(
                    id: _collegeId, isVisible: isAdmin, isHomePage: false)
                : const EmptyCollegeSelected(),
          ],
        ),
      ),
    );
  }
}
