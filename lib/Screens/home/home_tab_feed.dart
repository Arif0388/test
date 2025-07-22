import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/home/club_feed.dart';
import 'package:learningx_flutter_app/Screens/home/empty_college_selected.dart';
import 'package:learningx_flutter_app/Screens/home/event_feed.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/provider/college_provider.dart';
import '../club/club_fragment_page.dart';
import '../fest/fest_fragment_page.dart';

class HomeTabFeed extends ConsumerStatefulWidget {
  final String id;
  const HomeTabFeed({super.key, required this.id});

  @override
  ConsumerState<HomeTabFeed> createState() => _HomeTabFeedState();
}

class _HomeTabFeedState extends ConsumerState<HomeTabFeed>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _collegeId = "";
  String _currentUserId = "";
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
    if (_collegeId == widget.id) {
      var firebaseMessaging = FirebaseMessaging.instance;
      if (Platform.isMacOS || Platform.isIOS) {
        String? apnsToken = await firebaseMessaging.getAPNSToken();
        if (apnsToken != null) {
          await firebaseMessaging.subscribeToTopic(_collegeId);
        } else {
          await Future<void>.delayed(
            const Duration(
              seconds: 3,
            ),
          );
          apnsToken = await firebaseMessaging.getAPNSToken();
          if (apnsToken != null) {
            await firebaseMessaging.subscribeToTopic(_collegeId);
          }
        }
      } else {
        await firebaseMessaging.subscribeToTopic(_collegeId);
      }
    }
  }

  void setCollegeAdmin(isCollegeAdmin) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isCollegeAdmin', isCollegeAdmin);
  }

  @override
  Widget build(BuildContext context) {
    final collegeData = ref.watch(selectedCollegeProvider(widget.id));

    setState(() {
      isAdmin = collegeData.admin.any((item) => item.id == _currentUserId);
      setCollegeAdmin(isAdmin);
    });

    return Scaffold(
      body: Column(
        children: [
          Container(
            color: const Color.fromARGB(255, 211, 232, 255),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color.fromARGB(255, 56, 114, 220),
              unselectedLabelColor: Colors.black,
              indicatorColor: const Color.fromARGB(255, 56, 114, 220),
              tabs: const [
                Tab(text: 'Chat'),
                Tab(text: 'Event'),
                Tab(text: 'Club'),
                Tab(text: 'Fest'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                const ClubsScreen(),
                const EventsScreen(),
                (_collegeId != "" &&
                        _collegeId != dotenv.env['OTHER_COLLEGE_ID'])
                    ? ClubFragmentPage(
                        query: isAdmin
                            ? "?college=${collegeData.id}"
                            : "?college=${collegeData.id}&college_status[\$ne]=rejected",
                        page: const Divider(
                          color: Colors.black87,
                          height: 0,
                        ),
                        isVisible: true,
                        isCollegeAdmin: isAdmin,
                      )
                    : const EmptyCollegeSelected(),
                (_collegeId != "" &&
                        _collegeId != dotenv.env['OTHER_COLLEGE_ID'])
                    ? FestFragmentPage(
                        id: collegeData.id,
                        isVisible: isAdmin,
                        isHomePage: false,
                      )
                    : const EmptyCollegeSelected(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
