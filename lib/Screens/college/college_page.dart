import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learningx_flutter_app/Screens/club/club_fragment_page.dart';
import 'package:learningx_flutter_app/Screens/club/form/club_form1.dart';
import 'package:learningx_flutter_app/Screens/college/bottom_sheet_college_info.dart';
import 'package:learningx_flutter_app/Screens/college/college_about_fragment.dart';
import 'package:learningx_flutter_app/Screens/event/event_fragment_page.dart';
import 'package:learningx_flutter_app/Screens/event/form/event_form_page.dart';
import 'package:learningx_flutter_app/Screens/fest/fest_fragment_page.dart';
import 'package:learningx_flutter_app/api/model/college_model.dart';
import 'package:learningx_flutter_app/api/provider/college_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CollegeActivity extends ConsumerStatefulWidget {
  final String id;
  const CollegeActivity({super.key, required this.id});

  @override
  ConsumerState<CollegeActivity> createState() => _CollegeActivityState();
}

class _CollegeActivityState extends ConsumerState<CollegeActivity>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String _currentUserId = "";
  bool isAdmin = false;
  var isAuthenticated = false;

  @override
  void initState() {
    _loadCurrentUser();
    _tabController = TabController(length: 4, vsync: this);
    if (widget.id != "") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refresh();
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString("id") ?? "";
      isAuthenticated = prefs.getBool("isLoggedIn") ?? false;
    });
  }

  Future<void> _refresh() async {
    try {
      final collegeNotifier =
          ref.read(selectedCollegeProvider(widget.id).notifier);
      if (collegeNotifier.isLoading) {
        //  already fetching or fetched, no need to refresh
        return;
      }
      // not fetched, refresh
      await collegeNotifier.fetchCollege(widget.id);
    } catch (e) {
      // Handle error and navigate to the error page
      context.go("/error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final collegeData = ref.watch(selectedCollegeProvider(widget.id));

    setState(() {
      isAdmin = collegeData.admin.any((item) => item.id == _currentUserId);
    });

    final List<Widget> fragments = [
      ClubFragmentPage(
        query: isAdmin
            ? "?college=${collegeData.id}"
            : "?college=${collegeData.id}&college_status[\$ne]=rejected",
        page: const Divider(
          color: Colors.black87,
          height: 0,
        ),
      ),
      EventFragmentPage(
        query: isAdmin
            ? "?college=${collegeData.id}&verified=true"
            : "?college=${collegeData.id}&stepsDone=6&verified=true",
        page: const Divider(
          color: Colors.black87,
          height: 0,
        ),
      ),
      FestFragmentPage(
        id: collegeData.id,
        isVisible: false,
        isHomePage: false,
      ),
      CollegeAboutFragment(
        college: collegeData,
        isMyCampus: false,
      ),
    ];

    final List<Widget> appBarActions = [
      if (!isAuthenticated)
        OutlinedButton(
            onPressed: () {
              context.go("/apps");
            },
            child: const Text("Sign In")),
      if (isAuthenticated)
        IconButton(
          icon: const Icon(Icons.more_horiz),
          onPressed: () {
            final BottomSheetCollegeInfo sheetCollegeInfo =
                BottomSheetCollegeInfo();
            sheetCollegeInfo.showBottomSheet(
                context, collegeData, isAdmin, false);
          },
        ),
      const SizedBox(
        width: 8,
      )
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(collegeData.collegeName),
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
        elevation: 0,
        actions: appBarActions,
      ),
      body: DefaultTabController(
          length: 4,
          child: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverToBoxAdapter(
                    child: _buildInfoSection(collegeData),
                  ),
                  SliverOverlapAbsorber(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context),
                    sliver: SliverSafeArea(
                      top: false,
                      bottom: kIsWeb
                          ? false
                          : Platform.isIOS
                              ? false
                              : true,
                      sliver: SliverAppBar(
                        automaticallyImplyLeading: false,
                        pinned: true,
                        floating: true,
                        forceElevated: innerBoxIsScrolled,
                        backgroundColor: Colors.white,
                        expandedHeight: 0,
                        bottom: TabBar(
                          controller: _tabController,
                          indicatorColor: Colors.blue,
                          labelColor: Colors.blue,
                          unselectedLabelColor: Colors.black,
                          tabs: const [
                            Tab(text: 'Club'),
                            Tab(text: 'Event'),
                            Tab(text: 'Fest'),
                            Tab(text: 'About'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: fragments
                    .map((f) => SafeArea(
                          top: false,
                          bottom: false,
                          child: Builder(
                            builder: (BuildContext context) {
                              return NotificationListener<ScrollNotification>(
                                  onNotification: (scrollNotification) {
                                    return true;
                                  },
                                  child: f);
                            },
                          ),
                        ))
                    .toList(),
              ))),
    );
  }

  Widget _buildInfoSection(College collegeData) {
    return Column(children: [
      Container(
        color: Colors.white,
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(
              collegeData.collegeImg,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 8, bottom: 4),
              child: Text(
                collegeData.collegeName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on),
                  const SizedBox(width: 8),
                  Flexible(
                      child: Text(
                    collegeData.city.address,
                    textAlign: TextAlign.center,
                  )),
                ],
              ),
            ),
            if (isAdmin)
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ClubForm1Activity(
                                      collegeId: widget.id,
                                    )),
                          );
                        },
                        icon: const Icon(
                          Icons.group_add,
                          color: Colors.blue,
                        ),
                        label: const Text('Create Club'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.all(12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          foregroundColor: Colors.blue,
                          side: const BorderSide(
                              color: Colors.blue), // Set the border color here
                        ),
                      ),
                    ),
                    const SizedBox(width: 8), // Space between buttons
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EventFormPage(
                                      formData: {"collegeId": collegeData.id},
                                    )),
                          );
                        },
                        icon: const Icon(
                          Icons.event_available_rounded,
                          color: Colors.blue,
                        ),
                        label: const Text('Create Event'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.all(12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          foregroundColor: Colors.blue,
                          side: const BorderSide(
                              color: Colors.blue), // Set the border color here
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      const Divider(
        color: Color.fromARGB(255, 238, 238, 238),
        height: 4,
      ),
    ]);
  }
}
