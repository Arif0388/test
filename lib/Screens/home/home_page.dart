
// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:learningx_flutter_app/Screens/home/chat_tab_screen.dart';
import 'package:learningx_flutter_app/Screens/college/bottom_sheet_college_info.dart';
import 'package:learningx_flutter_app/Screens/extra/contact_us.dart';
import 'package:learningx_flutter_app/Screens/extra/setting_privacy.dart';
import 'package:learningx_flutter_app/Screens/home/club_feed.dart';
import 'package:learningx_flutter_app/Screens/home/empty_college_selected.dart';
import 'package:learningx_flutter_app/Screens/home/event_tab_feed.dart';
import 'package:learningx_flutter_app/Screens/profile/profile_page.dart';
import 'package:learningx_flutter_app/api/common/launch_url.dart';
import 'package:learningx_flutter_app/api/fcm/notification.dart';
import 'package:learningx_flutter_app/api/model/college_model.dart';
import 'package:learningx_flutter_app/api/provider/chat_room_provider.dart';
import 'package:learningx_flutter_app/api/provider/college_provider.dart';
import 'package:learningx_flutter_app/api/provider/extra_provider.dart';
import 'package:learningx_flutter_app/api/provider/notification_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:learningx_flutter_app/Screens/chats/chat_room_item.dart';
import '../club/form/club_form1.dart';
import '../club/form/club_form2.dart';
import '../club/form/club_form3.dart';
import '../event/form/event_form_page.dart';
import '../fest/fest_form.dart';

class MyHomePage extends ConsumerStatefulWidget {
  final int? index;
  const MyHomePage({super.key, this.index});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  int _currentIndex = 0;
  bool _isLoading = true;
  var unread_notification = 0;
  var unread_chat = 0;
  var _currentUserId = "";
  var _currentUserName = "user_name";
  var _currentUserImg =
      "https://learningx-s3.s3.ap-south-1.amazonaws.com/user.png";
  var _collegeId = "";
  final NotificationSetUp _noti = NotificationSetUp();
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadCurrentUser();
    setState(() => _isLoading = false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_collegeId.isNotEmpty) {
        await ref
            .read(selectedCollegeProvider(_collegeId).notifier)
            .fetchCollege(_collegeId);
      }
    });
    _pageController = PageController(initialPage: widget.index ?? 0);
    _currentIndex = widget.index ?? 0;
    countUnreadCount();
    _noti.configurePushNotifications(context);
    _noti.eventListenerCallback(context);
  }

  Future<void> _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('id') ?? "";
      _currentUserName = prefs.getString('displayName') ?? "";
      _currentUserImg = prefs.getString("userImg") ?? "";
      _collegeId = prefs.getString('college') ?? "";
      _isLoading = false;
    });
  }

  void countUnreadCount() async {
    int chatCount = await countUnreadChatRoomApi();
    int notiCount = await countUnreadNotificationApi();
    setState(() {
      unread_chat = chatCount;
      unread_notification = notiCount;
    });
  }

  void _updateIndex(int index) {
    _loadCurrentUser();
    countUnreadCount();
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> shareText() async {
    const String text =
        "Hey there, you can use the link below to download the app and join the campus clubs in a hassle free way! \nSee you in Campus Clubs.\n\n https://www.clubchat.live/apps";
    final byteData = await rootBundle.load('assets/images/learningx_icon.png');
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/learningx_icon.png');
    await file.writeAsBytes(byteData.buffer.asUint8List());

    Share.shareXFiles(
      [XFile(file.path)],
      text: text,
      subject: 'Check out this link!',
    );
  }

  // Method to create the logout dialog
  AlertDialog _buildLogoutDialog() {
    return AlertDialog(
      title: const Text("Are you sure?"),
      content: const Text("Do You want to Logout."),
      actions: [
        TextButton(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text("Logout"),
          onPressed: () async {
            await logUserActivityApi(context, {
              'activityType': "login",
              'college': _collegeId == "" ? null : _collegeId,
              'platform': kIsWeb ? "mWeb" : Platform.operatingSystem
            });
            final SharedPreferences prefs =
            await SharedPreferences.getInstance();
            await prefs.clear();

            final GoogleSignIn googleSignIn = GoogleSignIn();
            await googleSignIn.signOut();

            String azureId = prefs.getString('azureId') ?? "";
            if (azureId != "") {
              final Uri logoutUrl = Uri.parse(
                  'https://login.microsoftonline.com/common/oauth2/v2.0/logout');
              await LaunchUrl.openUrl(logoutUrl.toString());
            }
            Navigator.of(context).popUntil((route) => route.isFirst);
            context.go("/");
          },
        )
      ],
    );
  }

  // Profile page widget
  Widget _buildProfilePage() {
    return const ProfileActivity(id:'');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    College? collegeData;
    if (_collegeId.isNotEmpty) {
      collegeData = ref.watch(selectedCollegeProvider(_collegeId));
    }

    final List<Widget> screens = [
      EventTabFeed(id: _collegeId),
      const ChatTabScreen(),
      (_collegeId.isNotEmpty && _collegeId != dotenv.env['OTHER_COLLEGE_ID'])
          ? const ClubsScreen()
          : const EmptyCollegeSelected(),
      _buildProfilePage(),
    ];

    final List<String> appTitle = ["ClubChat", "Chats", "Clubs", "Profile"];

    void handleSearch() {
      context.push("/search");
    }

    void handleNotifications() {
      setState(() {
        unread_notification = 0;
      });
      context.push("/notifications");
    }

    void handleFloatingActionButton() {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: "Popup",
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) {
          return const SizedBox.shrink();
        },
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          return Transform.scale(
            scale: Curves.easeOutBack.transform(animation.value),
            child: Opacity(
              opacity: animation.value,
              child: const Center(
                child: GlassDialogContent(),
              ),
            ),
          );
        },
      );
    }

    final Widget notificationIcon = Stack(
      children: [
        const Icon(Icons.notifications),
        if (unread_notification > 0)
          Positioned(
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(6),
              ),
              constraints: const BoxConstraints(
                minWidth: 12,
                minHeight: 12,
              ),
              child: Text(
                '$unread_notification',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
    final List<List<Widget>> appBarActions = [
      [ // Home tab actions
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black),
          onPressed: handleSearch,
        ),
        IconButton(
          icon: notificationIcon,
          onPressed: handleNotifications,
        ),
        if (_collegeId != "" &&
            _collegeId != dotenv.env['OTHER_COLLEGE_ID'] &&
            collegeData != null)
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {
              var isAdmin =
              collegeData!.admin.any((item) => item.id == _currentUserId);
              final BottomSheetCollegeInfo sheetCollegeInfo =
              BottomSheetCollegeInfo();
              sheetCollegeInfo.showBottomSheet(
                  context, collegeData, isAdmin, true);
            },
          ),
        const SizedBox(width: 8)
      ],
      [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: handleSearch,
        ),
        IconButton(
          icon: notificationIcon,
          onPressed: handleNotifications,
        ),
        const SizedBox(width: 8)
      ],
      [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: handleSearch,
        ),
        IconButton(
          icon: notificationIcon,
          onPressed: handleNotifications,
        ),
        const SizedBox(width: 8)
      ],
      [
        const SizedBox(width: 8)
      ],
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        title: Text(
          appTitle[_currentIndex],
          style: const TextStyle(
            color: Color.fromARGB(255, 56, 114, 220),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: appBarActions[_currentIndex],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          _updateIndex(index);
        },
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color.fromARGB(255, 56, 114, 220),
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.chat_outlined),
                if (unread_chat > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$unread_chat',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Chats',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.groups_3_outlined),
            label: 'Clubs',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          _pageController.jumpToPage(index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        shape:const CircleBorder(),
        onPressed: handleFloatingActionButton,
        backgroundColor: const Color.fromARGB(255, 56, 114, 220),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

Widget buildEventOption({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
  IconData? trailingIcon,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.cyanAccent, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (trailingIcon != null)
            Icon(trailingIcon, color: Colors.white54, size: 20),
        ],
      ),
    ),
  );
}

Widget buildSubOption({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return Padding(
    padding: const EdgeInsets.only(left: 10),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
          ],
        ),
      ),
    ),
  );
}

class GlassDialogContent extends StatelessWidget {
  const GlassDialogContent({super.key});

  void _showClubOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(40),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildEventOption(
                    icon: Icons.build_circle_outlined,
                    iconColor: Colors.blueAccent,
                    label: 'Club Workshop',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ClubForm1Activity()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  buildEventOption(
                    icon: Icons.group_add_outlined,
                    iconColor: Colors.greenAccent,
                    label: 'New Club',
                    onTap: () {
                      Navigator.pop(context);
                      //New Club navigation here
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3), // <- Whiter glass background
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emoji_objects_rounded, size: 48, color: Colors.amber),
                  const SizedBox(height: 12),
                  const Text(
                    'Start Something New',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Responsive Grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      double itemWidth = (constraints.maxWidth - 16) / 2;
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          SizedBox(
                            width: itemWidth,
                            child: buildEventOption(
                              icon: Icons.account_tree_outlined,
                              iconColor: Colors.cyan,
                              label: 'Club',
                              onTap: () => _showClubOptions(context),
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: buildEventOption(
                              icon: Icons.build_circle_outlined,
                              iconColor: Colors.blue,
                              label: 'Workshop',
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ClubForm1Activity()),
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: buildEventOption(
                              icon: Icons.mic_external_on_rounded,
                              iconColor: Colors.deepOrange,
                              label: 'Event',
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const EventFormPage(formData: {})),
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: buildEventOption(
                              icon: Icons.celebration_outlined,
                              iconColor: Colors.purple,
                              label: 'Fest',
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const FestFormActivity(collegeId: '')),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.redAccent,
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEventOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize:13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}