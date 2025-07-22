import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learningx_flutter_app/Screens/club/about/channel_fragment_page.dart';
import 'package:learningx_flutter_app/Screens/club/club_fragment_page.dart';
import 'package:learningx_flutter_app/Screens/common/qr_creator.dart';
import 'package:learningx_flutter_app/Screens/council/add_club_to_council.dart';
import 'package:learningx_flutter_app/Screens/council/bottom_sheet_council_info.dart';
import 'package:learningx_flutter_app/Screens/council/council_about_fragment.dart';
import 'package:learningx_flutter_app/Screens/event/event_fragment_page.dart';
import 'package:learningx_flutter_app/Screens/event/form/event_form_page.dart';
import 'package:learningx_flutter_app/api/model/council_model.dart';
import 'package:learningx_flutter_app/api/provider/council_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CouncilPage extends ConsumerStatefulWidget {
  final String id;
  const CouncilPage({super.key, required this.id});

  @override
  ConsumerState<CouncilPage> createState() => _CouncilPageState();
}

class _CouncilPageState extends ConsumerState<CouncilPage>
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
      final councilNotifier =
          ref.read(selectedCouncilProvider(widget.id).notifier);
      if (councilNotifier.isLoading) {
        //  already fetching or fetched, no need to refresh
        return;
      }
      // not fetched, refresh
      await councilNotifier.fetchCouncil(widget.id);
    } catch (e) {
      // Handle error and navigate to the error page
      context.go("/error");
    }
  }

  void shareText(Council councilData) {
    String text =
        "to join our club !\n\n https://clubchat.live/club/about/${councilData.id}";
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => QrCreator(
                appBarText: "Invite members",
                sharedText: text,
                url: "https://clubchat.live/club/about/${councilData.id}",
                imageUrl: councilData.councilImg,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final councilData = ref.watch(selectedCouncilProvider(widget.id));

    setState(() {
      isAdmin = councilData.admin.any((item) => item.id == _currentUserId);
    });

    final List<Widget> fragments = [
      ClubFragmentPage(
        query: isAdmin
            ? "?council=${councilData.id}"
            : "?council=${councilData.id}&council_status[\$ne]=rejected",
        page: const Divider(
          color: Colors.black87,
          height: 0,
        ),
      ),
      ChannelFragmentPage(
        channels: councilData.clubItem.channels,
        clubItem: councilData.clubItem,
        page: const Divider(
          color: Colors.black87,
          height: 0,
        ),
      ),
      EventFragmentPage(
        query: isAdmin
            ? "?council=${councilData.id}"
            : "?council=${councilData.id}&stepsDone=6",
        page: const Divider(
          color: Colors.black87,
          height: 0,
        ),
      ),
      CouncilAboutFragment(council: councilData)
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
            final BottomSheetCouncilInfo sheetCollegeInfo =
                BottomSheetCouncilInfo();
            sheetCollegeInfo.showBottomSheet(context, councilData, isAdmin);
          },
        ),
      const SizedBox(
        width: 8,
      )
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(councilData.councilName),
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
                    child: _buildInfoSection(councilData),
                  ),
                  SliverOverlapAbsorber(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context),
                    sliver: SliverSafeArea(
                      top: false,
                      bottom: Platform.isIOS ? false : true,
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
                            Tab(text: 'Channel'),
                            Tab(text: 'Event'),
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

  Widget _buildInfoSection(Council councilData) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(
                    height: 45,
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 35),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                    child: Text(
                                  councilData.councilName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                )),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.verified,
                                  size: 15,
                                  color: Colors.blue,
                                ),
                              ],
                            ),
                            Text(
                              councilData.email,
                            ),
                            const SizedBox(width: 12),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.account_balance,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    "Google Developer",
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.black),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (!isAdmin)
                              SizedBox(
                                width: double.infinity, // Full width button
                                child: ElevatedButton.icon(
                                  onPressed: () async {},
                                  icon: const Icon(Icons.add_circle_outline),
                                  label: const Text('Request to join club'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                ),
                              ),
                            if (isAdmin) _buildAdminButtons(councilData),
                          ],
                        ),
                        if (isAdmin)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.share,
                                    color: Colors.white, size: 20),
                                onPressed: () {
                                  shareText(councilData);
                                },
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 0,
                left: (MediaQuery.of(context).size.width / 2) - 63,
                child: CircleAvatar(
                  radius: 45,
                  backgroundImage: NetworkImage(councilData.councilImg),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdminButtons(Council councilData) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddClubToCouncil(
                      collegeId: councilData.college.id,
                      councilId: councilData.id,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.group_add, color: Colors.blue),
              label: const Text('Add Club'),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
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
                            formData: {
                              "clubId": councilData.id,
                              "collegeId": councilData.college.id
                            },
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
                padding: const EdgeInsets.all(16),
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
    );
  }
}
