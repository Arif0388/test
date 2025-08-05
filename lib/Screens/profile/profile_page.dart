
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/common/launch_url.dart';
import '../../api/fcm/notification.dart';
import '../../api/provider/chat_room_provider.dart';
import '../../api/provider/college_provider.dart';
import '../../api/provider/extra_provider.dart';
import '../../api/provider/notification_provider.dart';
import '../../api/provider/profile_provider.dart';
import '../extra/contact_us.dart';
import '../extra/setting_privacy.dart';
import 'calander_screen.dart';

class ProfileActivity extends ConsumerStatefulWidget {
  final String id;
  // final int? index;
  const ProfileActivity({super.key, required  this.id});

  @override
  ConsumerState<ProfileActivity> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileActivity> {
  int _currentIndex = 0;
  bool _isLoading = true; // To handle loading state
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
      await ref
          .read(selectedCollegeProvider(_collegeId).notifier)
          .fetchCollege(_collegeId);
    });
    // Initialize PageController with widget.index or default to 0
    // _pageController = PageController(initialPage: widget.index ?? 0);
    // _currentIndex = widget.index ?? 0;
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
      _isLoading = false; // Data is fetched, stop loading
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

  @override
  Widget build(BuildContext context) {
    final profileData = ref.watch(profileProvider(_currentUserId));

    return Scaffold(
      backgroundColor:const Color(0xffF9FAFB),
      body:SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Column(
              children: [
              CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(_currentUserImg),
            ),
                const SizedBox(height: 10),
                Text(
                  _currentUserName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  profileData!.email ?? "Unknown Email",
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  profileIconButton(Icons.mail_sharp, "Message",(){}),
                  profileIconButton(Icons.calendar_today_outlined, "Calendar",(){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CalendarScreen()),
                    );
                  }),
                  const Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Color(0xFFE9ECFB),
                        child: Text("3", style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w700)),
                      ),
                      SizedBox(height: 4),
                      Text("Events", style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            if (_collegeId != "" &&
                _collegeId != dotenv.env['OTHER_COLLEGE_ID'])
            profileTile(Icons.school, "My Campus", onTap: () {
              context.push("/college/$_collegeId");
            }),
            profileTile(Icons.access_time_filled_sharp, "Upcoming Reminder", onTap: () {
              context.push("/reminder");
            }),
            profileTile(Icons.support_agent_outlined, "Contact Support", onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContactUs()),
              );
            }),
            profileTile(Icons.settings_sharp, "Settings & Privacy", onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        SettingAndPrivacy(id: _currentUserId)),
              );
            }),
            profileTile(Icons.share_sharp, "Invite and Share",
              onTap: () async {
              await shareText();
            },),
            const SizedBox(height: 10),
            Padding(
             padding: const EdgeInsets.only(left:10),
              child: ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.red),
                title: const Text("Logout", style: TextStyle(color: Colors.red)),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return _buildLogoutDialog();
                    },
                  );
                },
              ),
            ),
            if (kIsWeb)
              ListTile(
                leading: const Icon(Icons.install_mobile_outlined),
                title: const Text('Download App'),
                onTap: () {
                  context.go("/apps");
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget profileIconButton(IconData icon, String label,VoidCallback onTap) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left:10),
          child: InkWell(
            onTap:onTap,
            child: CircleAvatar(
              backgroundColor: const Color(0xFFE9ECFB),
              child: Icon(icon, color: Colors.indigo,size:20,weight:200,),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
  
  Widget profileTile(IconData icon, String title,{required VoidCallback onTap}) {
    return InkWell(
      onTap:onTap,
      child: Padding(
        padding: const EdgeInsets.only(left:8),
        child: ListTile(
          leading: Icon(icon, color: const Color(0xff1A237E),size:21,),
          title: Text(title,style:const TextStyle(color:Color(0xff000000),fontWeight:FontWeight.w500),),
          trailing: const Icon(Icons.chevron_right,color:Color(0xff9CA3AF),),
        ),
      ),
    );
  }

}

