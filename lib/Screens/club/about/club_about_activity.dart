import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learningx_flutter_app/Screens/club/about/bottom_sheet_club_info.dart';
import 'package:learningx_flutter_app/Screens/club/about/channel_fragment_page.dart';
import 'package:learningx_flutter_app/Screens/club/about/club_about_fragment.dart';
import 'package:learningx_flutter_app/Screens/common/qr_creator.dart';
import 'package:learningx_flutter_app/Screens/common/unauth_alert_dialog.dart';
import 'package:learningx_flutter_app/Screens/event/event_fragment_page.dart';
import 'package:learningx_flutter_app/Screens/event/form/event_form_page.dart';
import 'package:learningx_flutter_app/api/model/club_model.dart';
import 'package:learningx_flutter_app/api/provider/club_feed_provider.dart';
import 'package:learningx_flutter_app/api/provider/club_member_provider.dart';
import 'package:learningx_flutter_app/api/provider/club_provider.dart';
import 'package:learningx_flutter_app/api/provider/extra_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AboutClubScreen extends ConsumerStatefulWidget {
  final String clubId;
  const AboutClubScreen({super.key, required this.clubId});

  @override
  ConsumerState<AboutClubScreen> createState() => _AboutClubScreenState();
}

class _AboutClubScreenState extends ConsumerState<AboutClubScreen> {
  final ScrollController _scrollController = ScrollController();
  int _selectedFragmentIndex = 0;
  String _currentUserId = "";
  String _currentUsername = "";
  String _collegeId = "";
  bool isAdmin = false;
  bool isRestricted = false;
  bool isCollegeAdmin = false;
  String isMember = "notMember";
  var isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadCurrentUser();
    await _loadCurrentMember();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString("id") ?? "";
      _currentUsername = prefs.getString("username") ?? "";
      isAuthenticated = prefs.getBool("isLoggedIn") ?? false;
      _collegeId = prefs.getString("college") ?? "";
    });
  }

  Future<void> _loadCurrentMember() async {
    if (_currentUserId.isEmpty) return;

    Map<String, dynamic> map = HashMap();
    map['id'] = widget.clubId;
    map['user'] = _currentUserId;
    final memberAsyncValue =
        await ref.read(fetchSingleMemberProvider(map).future);

    if (memberAsyncValue.isNotEmpty) {
      setState(() {
        if (memberAsyncValue[0].active) {
          isMember = "member";
        } else {
          isMember = "requested";
        }
      });
    } else {
      setState(() {
        isMember = "notMember";
      });
    }
  }

  void _onFragmentChanged(int index) {
    setState(() {
      _selectedFragmentIndex = index;
    });
  }

  Future<void> _refresh() async {
    try {
      final clubNotifier =
          ref.read(selectedClubProvider(widget.clubId).notifier);
      if (clubNotifier.isLoading) {
        //  already fetching or fetched, no need to refresh
        return;
      }
      // not fetched, refresh
      await clubNotifier.fetchClub(widget.clubId);
    } catch (e) {
      // Handle error and navigate to the error page
      context.go("/error");
    }
  }

  void deleteClub(String clubId) {
    ref.read(yourClubFeedProvider.notifier).deleteClub(clubId);
    context.go("/home");
  }

  Future<void> updateClub(Map<String, dynamic> updatedData) async {
    await ref
        .read(selectedClubProvider(widget.clubId).notifier)
        .updateClubApi(context, updatedData);
  }

  void shareText(Club clubItem) {
    String text =
        "to join our club !\n\n https://clubchat.live/club/about/${clubItem.id}";
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => QrCreator(
                appBarText: "Invite members",
                sharedText: text,
                url: "https://clubchat.live/club/about/${clubItem.id}",
                imageUrl: clubItem.clubImg,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clubData = ref.watch(selectedClubProvider(widget.clubId));

    setState(() {
      isAdmin = clubData.admin.any((item) => item.id == _currentUserId);
      if (clubData.college != null) {
        isCollegeAdmin = clubData.college!.admin.contains(_currentUserId);
        isRestricted = clubData.college!.restricted &&
            !_currentUsername.contains(clubData.college!.emailDomain);
      }
    });

    final List<Widget> fragments = [
      if (isMember == "member")
        ChannelFragmentPage(
          channels: clubData.channels,
          clubItem: clubData.toClubItem(),
          page: _buildClubInfoSection(clubData),
        ),
      ClubAboutFragment(
        club: clubData,
        page: _buildClubInfoSection(clubData),
        isCollegeAdmin: isCollegeAdmin,
        isClubAdmin: isAdmin,
      ),
      EventFragmentPage(
          query: isAdmin
              ? "?club=${clubData.id}"
              : "?club=${clubData.id}&stepsDone=6",
          page: _buildClubInfoSection(clubData))
    ];

    if (clubData.clubName == "Loading...") {
      return Scaffold(
        backgroundColor:const Color(0xffF9FAFB),
          appBar: AppBar(
          leading:IconButton(onPressed:(){
            Navigator.pop(context);
          }, icon:const Icon(Icons.arrow_back_ios_new_rounded,color:Color(0xff000000),size:20,)),
    title: Text("Club Details", style: GoogleFonts.inter(fontSize:18,fontWeight: FontWeight.w400)),
    centerTitle: true,
    elevation: 0,
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    actions: [
    IconButton(onPressed:(){}, icon:const Icon(Icons.share_outlined))
    ],
    ),);

      //   Scaffold(
      //   appBar: AppBar(
      //     title: Text(clubData.clubName),
      //     backgroundColor: const Color.fromARGB(255, 211, 232, 255),
      //     titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
      //     actions: _buildAppBarActions(context, clubData),
      //   ),
      //   body: const Center(
      //     child: CircularProgressIndicator(),
      //   ),
      // );

    }

    else {
      return
        Scaffold(
            backgroundColor:const Color(0xffF9FAFB),
          appBar: AppBar(
          leading:IconButton(onPressed:(){}, icon:const Icon(Icons.arrow_back_ios_new_rounded,color:Color(0xff000000),size:20,)),
          title: Text("Club Details", style: GoogleFonts.inter(fontSize:18,fontWeight: FontWeight.w400)),
          centerTitle: true,
            elevation: 0,
         backgroundColor: Colors.white,
         foregroundColor: Colors.black,
         actions: [
         IconButton(onPressed:(){}, icon:const Icon(Icons.share_outlined))
    ],
    ),
          body: fragments[_selectedFragmentIndex]
      );

        // Scaffold(
        //   appBar: AppBar(
        //     title: Text(clubData.clubName),
        //     backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        //     titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
        //     actions: _buildAppBarActions(context, clubData),
        //   ),
        //   body: fragments[_selectedFragmentIndex]
        // );
    }
  }

  List<Widget> _buildAppBarActions(BuildContext context, Club clubData) {
    return [
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
            final BottomSheetClubInfo sheetClubInfo = BottomSheetClubInfo();
            sheetClubInfo.showBottomSheet(
                context,
                clubData.channels,
                clubData,
                _currentUserId,
                isAdmin,
                isCollegeAdmin,
                deleteClub,
                updateClub);
          },
        ),
      const SizedBox(width: 8),
    ];
  }

  Widget _buildClubInfoSection(Club clubData) {
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
                                  clubData.clubName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                )),
                                const SizedBox(width: 8),
                                if (clubData.collegeStatus == "verified")
                                  const Icon(
                                    Icons.verified,
                                    size: 15,
                                    color: Colors.blue,
                                  ),
                                if ((isCollegeAdmin || isAdmin) &&
                                    clubData.collegeStatus == "unverified")
                                  const Icon(
                                    Icons.verified_user_outlined,
                                    size: 15,
                                    color: Colors.grey,
                                  ),
                                if ((isCollegeAdmin || isAdmin) &&
                                    clubData.college != null &&
                                    clubData.collegeStatus == "rejected")
                                  Image.asset(
                                    "assets/images/under_approval.jpg",
                                    height: 32,
                                  ),
                              ],
                            ),
                            Text(
                              clubData.category,
                            ),
                            const SizedBox(width: 12),
                            if (clubData.councilName.isNotEmpty)
                              Text(
                                clubData.councilName,
                              ),
                            if (clubData.councilName.isNotEmpty)
                              const SizedBox(width: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.account_balance,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    clubData.learningXClub
                                        ? "Clubchat Official Club"
                                        : clubData.college != null
                                            ? clubData.college!.collegeName
                                            : "Private Club",
                                    style: const TextStyle(
                                        fontSize: 15, color: Colors.black),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (isMember != "member" && !isRestricted)
                              _buildJoinButtons(clubData),
                            if (isMember == "member")
                              _buildMemberButtons(clubData, isAdmin),
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
                                  shareText(clubData);
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
                  backgroundImage: NetworkImage(clubData.clubImg),
                ),
              ),
            ],
          ),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 16),
              if (isMember == "member") _buildFragmentButtons('Channel', 0),
              if (isMember == "member") const SizedBox(width: 8),
              _buildFragmentButtons('About', (isMember == "member") ? 1 : 0),
              const SizedBox(width: 8),
              _buildFragmentButtons('Event', (isMember == "member") ? 2 : 1),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMemberButtons(Club clubData, bool isClubAdmin) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                context.push("/club/member/${clubData.id}", extra: {
                  'isAdmin': isClubAdmin,
                });
              },
              icon: const Icon(Icons.group),
              label: const Text('View Members'),
              style: ElevatedButton.styleFrom(
                elevation: 1,
                textStyle: const TextStyle(fontSize: 14),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8), // Space between buttons
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                if (isClubAdmin) {
                  Map<String, String> formData = HashMap();
                  formData['clubId'] = widget.clubId;
                  if (clubData.college != null &&
                      clubData.collegeStatus != "rejected") {
                    formData['collegeId'] = clubData.college!.id;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            EventFormPage(formData: formData)),
                  );
                } else {
                  shareText(clubData);
                }
              },
              icon: Icon(isClubAdmin
                  ? Icons.event_available_outlined
                  : Icons.share_outlined),
              label: Text(isClubAdmin ? 'Create Event' : 'Invite Members'),
              style: ElevatedButton.styleFrom(
                elevation: 1,
                textStyle: const TextStyle(fontSize: 14),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinButtons(Club club) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
      child: Column(
        children: [
          if (isMember == "notMember")
            SizedBox(
              width: double.infinity, // Full width button
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (isAuthenticated) {
                    Map<String, dynamic> map = HashMap();
                    map['club'] = widget.clubId;
                    map['active'] = club.learningXClub;
                    await requestToJoinClubApi(context, map);
                    await logUserActivityApi(context, {
                      'activityType': "joinedClub",
                      'college': _collegeId.isEmpty ? null : _collegeId,
                      'platform': kIsWeb ? "mWeb" : Platform.operatingSystem
                    });
                    setState(() {
                      isMember = club.learningXClub ? "member" : "requested";
                    });
                  } else {
                    AuthDialog.showUnauthDialog(context);
                  }
                },
                icon: const Icon(Icons.add_circle_outline),
                label: Text(
                    club.learningXClub ? 'Join now' : 'Request to join club'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
          if (isMember == "requested")
            SizedBox(
              width: double.infinity, // Full width button
              child: ElevatedButton.icon(
                onPressed: () async {
                  Map<String, dynamic> map = HashMap();
                  map['club'] = widget.clubId;
                  map['user'] = _currentUserId;
                  await deleteClubMemberApi(context, map);
                  setState(() {
                    isMember = "notMember";
                  });
                },
                icon: const Icon(Icons.close),
                label: const Text('Cancel request'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFragmentButtons(String text, int index) {
    bool isActive = _selectedFragmentIndex == index;

    return isActive
        ? ElevatedButton(
            onPressed: () {
              _onFragmentChanged(index);
            },
            style: ButtonStyle(
              textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 13)),
              backgroundColor: WidgetStateProperty.all(
                  Colors.blue), // Active button background color
              foregroundColor: WidgetStateProperty.all(
                  Colors.white), // Active button text color
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            child: Text(text),
          )
        : OutlinedButton(
            onPressed: () {
              _onFragmentChanged(index);
            },
            style: ButtonStyle(
              textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 13)),
              foregroundColor: WidgetStateProperty.all(
                  Colors.black), // Inactive button text color
              side: WidgetStateProperty.all(const BorderSide(
                  color: Colors.white)), // Inactive button border color
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            child: Text(text),
          );
  }
}
