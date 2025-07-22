import 'dart:collection';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:learningx_flutter_app/Screens/club/club_fragment_page.dart';
import 'package:learningx_flutter_app/Screens/club/form/club_form1.dart';
import 'package:learningx_flutter_app/Screens/college/college_about_fragment.dart';
import 'package:learningx_flutter_app/Screens/college/college_form.dart';
import 'package:learningx_flutter_app/Screens/college/college_selection_search.dart';
import 'package:learningx_flutter_app/Screens/event/event_fragment_page.dart';
import 'package:learningx_flutter_app/Screens/event/form/event_form_page.dart';
import 'package:learningx_flutter_app/Screens/fest/fest_form.dart';
import 'package:learningx_flutter_app/Screens/fest/fest_fragment_page.dart';
import 'package:learningx_flutter_app/Screens/home/campus_ambassador_card.dart';
import 'package:learningx_flutter_app/api/model/college_model.dart';
import 'package:learningx_flutter_app/api/provider/college_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CampusPage extends ConsumerStatefulWidget {
  final String id;
  const CampusPage({super.key, required this.id});

  @override
  ConsumerState<CampusPage> createState() => _CampusPageState();
}

class _CampusPageState extends ConsumerState<CampusPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String _collegeId = "";
  String _currentUserId = "";
  bool isAdmin = false;
  bool isYourCollege = false;
  bool _isCampusAmbassadorCardVisible = false;

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
    _tabController.dispose();
    super.dispose();
  }

  _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _collegeId = prefs.getString('college') ?? "";
      _currentUserId = prefs.getString("id") ?? "";
      isYourCollege = _collegeId == widget.id;
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

  Future<void> _refresh() async {
    final collegeNotifier =
        ref.read(selectedCollegeProvider(widget.id).notifier);
    if (collegeNotifier.isLoading) {
      //  already fetching or fetched, no need to refresh
      return;
    }
    // not fetched, refresh
    await collegeNotifier.fetchCollege(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    College collegeData = College(
        id: widget.id,
        admin: [],
        collegeName: "",
        collegeImg:
            "https://learningx-s3.s3.ap-south-1.amazonaws.com/image_2_1.png",
        description: "",
        email: "",
        website: "",
        instagram: "",
        linkedIn: "",
        restricted: false,
        emailDomain: "",
        verified: true,
        city: City(address: ""));
    if (widget.id != "") {
      collegeData = ref.watch(selectedCollegeProvider(widget.id));
    }

    setState(() {
      isAdmin = collegeData.admin.any((item) => item.id == _currentUserId);
    });

    return Scaffold(
      body: (widget.id == "" || widget.id == dotenv.env['OTHER_COLLEGE_ID'])
          ? Container(
              padding: const EdgeInsets.all(64),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "You haven't selected any college or\n Selected College as Other",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      Map<String, dynamic> map = HashMap();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CollegeSelectionWidget(map: map),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.add_box,
                      color: Color.fromARGB(255, 56, 114, 220),
                    ),
                    label: const Text(
                      'Select your campus',
                      style: TextStyle(
                        color: Color.fromARGB(255, 56, 114, 220),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  if (widget.id == dotenv.env['OTHER_COLLEGE_ID'])
                    const Text("OR"),
                  const SizedBox(
                    height: 8,
                  ),
                  if (widget.id == dotenv.env['OTHER_COLLEGE_ID'])
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CollegeFormActivity(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.add_box,
                        color: Color.fromARGB(255, 56, 114, 220),
                      ),
                      label: const Text(
                        'Create your college Page',
                        style: TextStyle(
                          color: Color.fromARGB(255, 56, 114, 220),
                        ),
                      ),
                    ),
                ],
              ),
            )
          : Stack(children: [
              Column(
                children: [
                  // Container(
                  //   color: const Color.fromARGB(255, 238, 238, 238),
                  //   padding:
                  //       const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  //   child: Container(
                  //     padding: const EdgeInsets.all(8),
                  //     decoration: BoxDecoration(
                  //       color: Colors.white,
                  //       borderRadius: BorderRadius.circular(20),
                  //     ),
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.center,
                  //       children: [
                  //         Row(
                  //           mainAxisAlignment: MainAxisAlignment.center,
                  //           children: [
                  //             Flexible(
                  //               child: RichText(
                  //                 textAlign: TextAlign.center,
                  //                 text: TextSpan(
                  //                   children: [
                  //                     TextSpan(
                  //                       text: collegeData.collegeName,
                  //                       style: const TextStyle(
                  //                         fontWeight: FontWeight.bold,
                  //                         fontSize: 18,
                  //                         color: Colors.black,
                  //                       ),
                  //                     ),
                  //                     WidgetSpan(
                  //                       child: Padding(
                  //                         padding:
                  //                             const EdgeInsets.only(left: 4.0),
                  //                         child: IconButton(
                  //                           onPressed: () {
                  //                             String text =
                  //                                 "to discover clubs and events of the campus ${collegeData.collegeName} !\n\n https://clubchat.live/college/${collegeData.id}";
                  //                             Navigator.push(
                  //                               context,
                  //                               MaterialPageRoute(
                  //                                   builder: (context) =>
                  //                                       QrCreator(
                  //                                         appBarText:
                  //                                             "Share Campus",
                  //                                         sharedText: text,
                  //                                         url:
                  //                                             "https://clubchat.live/college/${collegeData.id}",
                  //                                         imageUrl: collegeData.collegeImg,
                  //                                       )),
                  //                             );
                  //                           },
                  //                           icon: const Icon(
                  //                             Icons.share_outlined,
                  //                             size: 18,
                  //                           ),
                  //                           color: Colors.blue,
                  //                         ),
                  //                       ),
                  //                       alignment: PlaceholderAlignment.middle,
                  //                     ),
                  //                   ],
                  //                 ),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  Container(
                    color: Colors.white,
                    child: TabBar(
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

                  // Tab Bar View
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
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
                              ? "?college=${collegeData.id}"
                              : "?college=${collegeData.id}&stepsDone=6",
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
                          isMyCampus: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_isCampusAmbassadorCardVisible)
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: CampusAmbassadorCard(),
                ),
            ]),
      floatingActionButton: isAdmin
          ? SpeedDial(
              animatedIcon: AnimatedIcons.add_event,
              animatedIconTheme: const IconThemeData(color: Colors.white),
              backgroundColor: const Color.fromARGB(255, 56, 114, 220),
              overlayColor: Colors.black,
              overlayOpacity: 0.5,
              spacing: 16,
              elevation: 6.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              children: [
                SpeedDialChild(
                  child: const Icon(
                    Icons.groups_outlined,
                    color: Color.fromARGB(255, 56, 114, 220),
                  ),
                  label: 'Create Club',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClubForm1Activity(
                          collegeId: widget.id,
                        ),
                      ),
                    );
                  },
                ),
                SpeedDialChild(
                  child: const Icon(
                    Icons.event_available,
                    color: Color.fromARGB(255, 56, 114, 220),
                  ),
                  label: 'Create Event',
                  onTap: () {
                    Map<String, String> formData = HashMap();
                    formData['collegeId'] = widget.id;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              EventFormPage(formData: formData)),
                    );
                  },
                ),
                SpeedDialChild(
                  child: const Icon(
                    Icons.festival_outlined,
                    color: Color.fromARGB(255, 56, 114, 220),
                  ),
                  label: 'Create Fest',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FestFormActivity(
                          collegeId: widget.id,
                        ),
                      ),
                    );
                  },
                ),
              ],
            )
          : Visibility(
              visible: collegeData.admin.length == 1 &&
                  collegeData.admin.any(
                    (item) => item.id == dotenv.env['LEARNINGX_ADMIN_ID'],
                  ),
              child: FloatingActionButton(
                backgroundColor: const Color.fromARGB(255, 56, 114, 220),
                onPressed: () {
                  setState(() {
                    _isCampusAmbassadorCardVisible =
                        !_isCampusAmbassadorCardVisible;
                  });
                },
                child: const Icon(
                  Icons.mail_outline,
                  color: Colors.white,
                ),
              ),
            ),
    );
  }
}
