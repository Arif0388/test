// // ignore_for_file: use_build_context_synchronously, non_constant_identifier_names
// import 'dart:io';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:learningx_flutter_app/Screens/college/bottom_sheet_college_info.dart';
// import 'package:learningx_flutter_app/Screens/extra/contact_us.dart';
// import 'package:learningx_flutter_app/Screens/extra/setting_privacy.dart';
// import 'package:learningx_flutter_app/Screens/home/club_feed.dart';
// import 'package:learningx_flutter_app/Screens/home/empty_college_selected.dart';
// import 'package:learningx_flutter_app/Screens/home/event_tab_feed.dart';
// import 'package:learningx_flutter_app/api/common/launch_url.dart';
// import 'package:learningx_flutter_app/api/fcm/notification.dart';
// import 'package:learningx_flutter_app/api/model/college_model.dart';
// import 'package:learningx_flutter_app/api/provider/chat_room_provider.dart';
// import 'package:learningx_flutter_app/api/provider/college_provider.dart';
// import 'package:learningx_flutter_app/api/provider/extra_provider.dart';
// import 'package:learningx_flutter_app/api/provider/notification_provider.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class MyHomePage extends ConsumerStatefulWidget {
//   final int? index;
//   const MyHomePage({super.key, this.index});
//
//   @override
//   ConsumerState<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends ConsumerState<MyHomePage> {
//   int _currentIndex = 0;
//   bool _isLoading = true; // To handle loading state
//   var unread_notification = 0;
//   var unread_chat = 0;
//   var _currentUserId = "";
//   var _currentUserName = "user_name";
//   var _currentUserImg =
//       "https://learningx-s3.s3.ap-south-1.amazonaws.com/user.png";
//   var _collegeId = "";
//   final NotificationSetUp _noti = NotificationSetUp();
//   late final PageController _pageController;
//
//   @override
//   void initState() {
//     super.initState();
//     _initialize();
//   }
//
//   Future<void> _initialize() async {
//     await _loadCurrentUser();
//     setState(() => _isLoading = false);
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await ref
//           .read(selectedCollegeProvider(_collegeId).notifier)
//           .fetchCollege(_collegeId);
//     });
//     // Initialize PageController with widget.index or default to 0
//     _pageController = PageController(initialPage: widget.index ?? 0);
//     _currentIndex = widget.index ?? 0;
//     countUnreadCount();
//     _noti.configurePushNotifications(context);
//     _noti.eventListenerCallback(context);
//   }
//
//   Future<void> _loadCurrentUser() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _currentUserId = prefs.getString('id') ?? "";
//       _currentUserName = prefs.getString('displayName') ?? "";
//       _currentUserImg = prefs.getString("userImg") ?? "";
//       _collegeId = prefs.getString('college') ?? "";
//       _isLoading = false; // Data is fetched, stop loading
//     });
//   }
//
//   void countUnreadCount() async {
//     int chatCount = await countUnreadChatRoomApi();
//     int notiCount = await countUnreadNotificationApi();
//     setState(() {
//       unread_chat = chatCount;
//       unread_notification = notiCount;
//     });
//   }
//
//   void _updateIndex(int index) {
//     _loadCurrentUser();
//     countUnreadCount();
//     setState(() {
//       _currentIndex = index;
//     });
//   }
//
//   Future<void> shareText() async {
//     const String text =
//         "Hey there, you can use the link below to download the app and join the campus clubs in a hassle free way! \nSee you in Campus Clubs.\n\n https://www.clubchat.live/apps";
//     final byteData = await rootBundle.load('assets/images/learningx_icon.png');
//     final tempDir = await getTemporaryDirectory();
//     final file = File('${tempDir.path}/learningx_icon.png');
//     await file.writeAsBytes(byteData.buffer.asUint8List());
//
//     Share.shareXFiles(
//       [XFile(file.path)],
//       text: text,
//       subject: 'Check out this link!',
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     College? collegeData;
//     if (_collegeId.isNotEmpty) {
//       collegeData = ref.watch(selectedCollegeProvider(_collegeId));
//     }
//
//     final List<Widget> screens = [
//       EventTabFeed(id: _collegeId),
//       (_collegeId.isNotEmpty && _collegeId != dotenv.env['OTHER_COLLEGE_ID'])
//           ? const ClubsScreen()
//           : const EmptyCollegeSelected(),
//     ];
//     final List<String> appTitle = ["Home", "Community"];
//     void handleSearch() {
//       context.push("/search");
//     }
//
//     void handleNotifications() {
//       setState(() {
//         unread_notification = 0;
//       });
//       context.push("/notifications");
//     }
//
//     final Widget icon = Stack(
//       children: [
//         const Icon(Icons.notifications),
//         if (unread_notification > 0)
//           Positioned(
//             right: 0,
//             child: Container(
//               padding: const EdgeInsets.all(1),
//               decoration: BoxDecoration(
//                 color: Colors.red,
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               constraints: const BoxConstraints(
//                 minWidth: 12,
//                 minHeight: 12,
//               ),
//               child: Text(
//                 '$unread_notification',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 8,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ),
//       ],
//     );
//
//     final List<List<Widget>> appBarActions = [
//       [
//         IconButton(
//           icon: const Icon(
//             Icons.search,
//             color: Colors.black,
//           ),
//           onPressed: () {
//             handleSearch();
//           },
//         ),
//         IconButton(
//           icon: icon,
//           onPressed: () {
//             handleNotifications();
//           },
//         ),
//         if (_collegeId != "" && _collegeId != dotenv.env['OTHER_COLLEGE_ID'])
//           IconButton(
//             icon: const Icon(Icons.more_horiz),
//             onPressed: () {
//               var isAdmin =
//                   collegeData!.admin.any((item) => item.id == _currentUserId);
//               final BottomSheetCollegeInfo sheetCollegeInfo =
//                   BottomSheetCollegeInfo();
//               sheetCollegeInfo.showBottomSheet(
//                   context, collegeData, isAdmin, true);
//             },
//           ),
//         const SizedBox(width: 8)
//       ],
//       [
//         IconButton(
//           icon: const Icon(Icons.search),
//           onPressed: () {
//             handleSearch();
//           },
//         ),
//         IconButton(
//           icon: icon,
//           onPressed: () {
//             handleNotifications();
//           },
//         ),
//         const SizedBox(width: 8)
//       ],
//     ];
//
//     AlertDialog alert = AlertDialog(
//       title: const Text("Are you sure?"),
//       content: const Text("Do You want to Logout."),
//       actions: [
//         TextButton(
//           child: const Text("Cancel"),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//         TextButton(
//           child: const Text("Logout"),
//           onPressed: () async {
//             await logUserActivityApi(context, {
//               'activityType': "login",
//               'college': _collegeId == "" ? null : _collegeId,
//               'platform': kIsWeb ? "mWeb" : Platform.operatingSystem
//             });
//             final SharedPreferences prefs =
//                 await SharedPreferences.getInstance();
//             await prefs.clear();
//
//             final GoogleSignIn googleSignIn = GoogleSignIn();
//             await googleSignIn.signOut();
//
//             String azureId = prefs.getString('azureId') ?? "";
//             if (azureId != "") {
//               final Uri logoutUrl = Uri.parse(
//                   'https://login.microsoftonline.com/common/oauth2/v2.0/logout');
//               await LaunchUrl.openUrl(logoutUrl.toString());
//             }
//             Navigator.of(context).popUntil((route) => route.isFirst);
//             context.go("/");
//           },
//         )
//       ],
//     );
//
//     return DefaultTabController(
//       length: screens.length,
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: const Color.fromARGB(255, 211, 232, 255),
//           title: Center(
//             child: Text(
//               appTitle[_currentIndex],
//               style: const TextStyle(
//                 color: Color.fromARGB(255, 56, 114, 220),
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           leading: Builder(
//             builder: (context) => GestureDetector(
//               onTap: () {
//                 Scaffold.of(context).openDrawer();
//               },
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: CircleAvatar(
//                   radius: 16,
//                   backgroundImage: NetworkImage(_currentUserImg),
//                 ),
//               ),
//             ),
//           ),
//           actions: appBarActions[0],
//         ),
//         body: PageView(
//           controller: _pageController,
//           onPageChanged: (index) {
//             _updateIndex(index); // Centralized state update logic
//           },
//           children: screens,
//         ),
//         bottomNavigationBar: BottomNavigationBar(
//           backgroundColor: Colors.white,
//           selectedItemColor: const Color.fromARGB(255, 56, 114, 220),
//           currentIndex: _currentIndex,
//           type: BottomNavigationBarType.fixed,
//           showSelectedLabels: false, // Hide selected item labels
//           showUnselectedLabels: false, // Hide unselected item labels
//           items: const [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.home),
//               label: '',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.groups_3_outlined),
//               label: '',
//             ),
//           ],
//           onTap: (index) {
//             _pageController.jumpToPage(index); // Only navigates to the page
//           },
//         ),
//         drawer: Drawer(
//           backgroundColor: Colors.white,
//           child: ListView(
//             padding: const EdgeInsets.only(left: 8),
//             children: [
//               Container(
//                 margin: const EdgeInsets.only(top: 16),
//                 height: MediaQuery.of(context).size.height / 4.5,
//                 child: Stack(
//                   children: [
//                     Center(
//                       child: DrawerHeader(
//                         child: Column(
//                           children: [
//                             GestureDetector(
//                                 onTap: () async {
//                                   Navigator.pop(context);
//                                   // context.push("/profile/$_currentUserId");
//                                   context.push("/profile2/$_currentUserId");
//                                 },
//                                 child: CircleAvatar(
//                                   radius: 29,
//                                   backgroundImage: NetworkImage(
//                                     _currentUserImg,
//                                   ),
//                                 )),
//                             const SizedBox(height: 8),
//                             Text(_currentUserName),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               ListTile(
//                 leading: const Icon(Icons.schedule),
//                 title: const Text('Upcoming Reminder'),
//                 onTap: () {
//                   // Navigate to Upcoming Sessions page
//                   Navigator.pop(context);
//                   context.push("/reminder");
//                 },
//               ),
//               if (_collegeId != "" &&
//                   _collegeId != dotenv.env['OTHER_COLLEGE_ID'])
//                 ListTile(
//                   leading: const Icon(Icons.school_outlined),
//                   title: const Text('My Campus'),
//                   onTap: () {
//                     // Navigate to Upcoming Sessions page
//                     Navigator.pop(context);
//                     context.push("/college/$_collegeId");
//                   },
//                 ),
//               ListTile(
//                 leading: const Icon(Icons.contact_phone), // Icon added here
//                 title: const Text('Contact Us'),
//                 onTap: () {
//                   // Navigate to Contact Us page
//                   Navigator.pop(context);
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => const ContactUs()),
//                   );
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.settings_outlined), // Icon added here
//                 title: const Text('Setting & Privacy'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) =>
//                             SettingAndPrivacy(id: _currentUserId)),
//                   );
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.share), // Icon added here
//                 title: const Text('Invite and Share'),
//                 onTap: () async {
//                   await shareText();
//                   Navigator.pop(context);
//                 },
//               ),
//               if (kIsWeb)
//                 ListTile(
//                   leading: const Icon(
//                       Icons.install_mobile_outlined), // Icon added here
//                   title: const Text('Download App'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     context.go("/apps");
//                   },
//                 ),
//               ListTile(
//                 leading: const Icon(Icons.logout), // Icon added here
//                 title: const Text('Logout'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   showDialog(
//                     context: context,
//                     builder: (BuildContext context) {
//                       return alert;
//                     },
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:learningx_flutter_app/Screens/college/bottom_sheet_college_info.dart';
// import 'package:learningx_flutter_app/Screens/extra/setting_privacy.dart';
// import 'package:learningx_flutter_app/Screens/home/club_feed.dart';
// import 'package:learningx_flutter_app/Screens/home/empty_college_selected.dart';
// import 'package:learningx_flutter_app/Screens/home/event_tab_feed.dart';
// import 'package:learningx_flutter_app/api/common/launch_url.dart';
// import 'package:learningx_flutter_app/api/fcm/notification.dart';
// import 'package:learningx_flutter_app/api/model/college_model.dart';
// import 'package:learningx_flutter_app/api/provider/chat_room_provider.dart';
// import 'package:learningx_flutter_app/api/provider/college_provider.dart';
// import 'package:learningx_flutter_app/api/provider/extra_provider.dart';
// import 'package:learningx_flutter_app/api/provider/notification_provider.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../extra/contact_us.dart';
//
// class MyHomePage extends ConsumerStatefulWidget {
//   final int? index;
//   const MyHomePage({super.key, this.index});
//
//   @override
//   ConsumerState<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends ConsumerState<MyHomePage> {
//   bool _isFabOpen = false;
//   int _currentIndex = 0;
//   bool _isLoading = true; // To handle loading state
//   var unread_notification = 0;
//   var unread_chat = 0;
//   var _currentUserId = "";
//   var _currentUserName = "user_name";
//   var _currentUserImg =
//       "https://learningx-s3.s3.ap-south-1.amazonaws.com/user.png";
//   var _collegeId = "";
//   final NotificationSetUp _noti = NotificationSetUp();
//   late final PageController _pageController;
//
//   @override
//   void initState() {
//     super.initState();
//     _initialize();
//   }
//
//   Future<void> _initialize() async {
//     await _loadCurrentUser();
//     setState(() => _isLoading = false);
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await ref
//           .read(selectedCollegeProvider(_collegeId).notifier)
//           .fetchCollege(_collegeId);
//     });
//     // Initialize PageController with widget.index or default to 0
//     _pageController = PageController(initialPage: widget.index ?? 0);
//     _currentIndex = widget.index ?? 0;
//     countUnreadCount();
//     _noti.configurePushNotifications(context);
//     _noti.eventListenerCallback(context);
//   }
//
//   Future<void> _loadCurrentUser() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _currentUserId = prefs.getString('id') ?? "";
//       _currentUserName = prefs.getString('displayName') ?? "";
//       _currentUserImg = prefs.getString("userImg") ?? "";
//       _collegeId = prefs.getString('college') ?? "";
//       _isLoading = false; // Data is fetched, stop loading
//     });
//   }
//
//   void countUnreadCount() async {
//     int chatCount = await countUnreadChatRoomApi();
//     int notiCount = await countUnreadNotificationApi();
//     setState(() {
//       unread_chat = chatCount;
//       unread_notification = notiCount;
//     });
//   }
//
//   void _updateIndex(int index) {
//     _loadCurrentUser();
//     countUnreadCount();
//     setState(() {
//       _currentIndex = index;
//     });
//   }
//
//   Future<void> shareText() async {
//     const String text =
//         "Hey there, you can use the link below to download the app and join the campus clubs in a hassle free way! \nSee you in Campus Clubs.\n\n https://www.clubchat.live/apps";
//     final byteData = await rootBundle.load('assets/images/learningx_icon.png');
//     final tempDir = await getTemporaryDirectory();
//     final file = File('${tempDir.path}/learningx_icon.png');
//     await file.writeAsBytes(byteData.buffer.asUint8List());
//
//     Share.shareXFiles(
//       [XFile(file.path)],
//       text: text,
//       subject: 'Check out this link!',
//     );
//   }
//
//   // Method to create the logout dialog
//   AlertDialog _buildLogoutDialog() {
//     return AlertDialog(
//       title: const Text("Are you sure?"),
//       content: const Text("Do You want to Logout."),
//       actions: [
//         TextButton(
//           child: const Text("Cancel"),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//         TextButton(
//           child: const Text("Logout"),
//           onPressed: () async {
//             await logUserActivityApi(context, {
//               'activityType': "login",
//               'college': _collegeId == "" ? null : _collegeId,
//               'platform': kIsWeb ? "mWeb" : Platform.operatingSystem
//             });
//             final SharedPreferences prefs =
//             await SharedPreferences.getInstance();
//             await prefs.clear();
//
//             final GoogleSignIn googleSignIn = GoogleSignIn();
//             await googleSignIn.signOut();
//
//             String azureId = prefs.getString('azureId') ?? "";
//             if (azureId != "") {
//               final Uri logoutUrl = Uri.parse(
//                   'https://login.microsoftonline.com/common/oauth2/v2.0/logout');
//               await LaunchUrl.openUrl(logoutUrl.toString());
//             }
//             Navigator.of(context).popUntil((route) => route.isFirst);
//             context.go("/");
//           },
//         )
//       ],
//     );
//   }
//
//   // Placeholder for Chats screen
//   Widget _buildChatsScreen() {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.chat_outlined,
//               size: 80,
//               color: Colors.grey.shade400,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Chats',
//               style: TextStyle(
//                 fontSize: 24,
//                 color: Colors.grey.shade600,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Your conversations will appear here',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey.shade500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Profile page widget
//   Widget _buildProfilePage() {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           // Profile header
//           Container(
//             margin: const EdgeInsets.only(top: 32, bottom: 32),
//             child: Center(
//               child: Column(
//                 children: [
//                   GestureDetector(
//                     onTap: () async {
//                       context.push("/profile2/$_currentUserId");
//                     },
//                     child: CircleAvatar(
//                       radius: 40,
//                       backgroundImage: NetworkImage(_currentUserImg),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     _currentUserName,
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           // Menu items
//           ListTile(
//             leading: const Icon(Icons.schedule),
//             title: const Text('Upcoming Reminder'),
//             onTap: () {
//               context.push("/reminder");
//             },
//           ),
//           if (_collegeId != "" &&
//               _collegeId != dotenv.env['OTHER_COLLEGE_ID'])
//             ListTile(
//               leading: const Icon(Icons.school_outlined),
//               title: const Text('My Campus'),
//               onTap: () {
//                 context.push("/college/$_collegeId");
//               },
//             ),
//           ListTile(
//             leading: const Icon(Icons.contact_phone),
//             title: const Text('Contact Us'),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const ContactUs()),
//                 // MaterialPageRoute(builder: (context) => const ContactUs()),
//               );
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.settings_outlined),
//             title: const Text('Setting & Privacy'),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) =>
//                         SettingAndPrivacy(id: _currentUserId)),
//               );
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.share),
//             title: const Text('Invite and Share'),
//             onTap: () async {
//               await shareText();
//             },
//           ),
//           if (kIsWeb)
//             ListTile(
//               leading: const Icon(Icons.install_mobile_outlined),
//               title: const Text('Download App'),
//               onTap: () {
//                 context.go("/apps");
//               },
//             ),
//           ListTile(
//             leading: const Icon(Icons.logout),
//             title: const Text('Logout'),
//             onTap: () {
//               showDialog(
//                 context: context,
//                 builder: (BuildContext context) {
//                   return _buildLogoutDialog();
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Scaffold(
//         backgroundColor:const Color(0xffF9FAFB),
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     College? collegeData;
//     if (_collegeId.isNotEmpty) {
//       collegeData = ref.watch(selectedCollegeProvider(_collegeId));
//     }
//
//     final List<Widget> screens = [
//       EventTabFeed(id: _collegeId), // Home screen
//       _buildChatsScreen(), // Chats screen
//       (_collegeId.isNotEmpty && _collegeId != dotenv.env['OTHER_COLLEGE_ID'])
//           ? const ClubsScreen()
//           : const EmptyCollegeSelected(), // Clubs screen
//       _buildProfilePage(), // Profile screen
//     ];
//
//     final List<String> appTitle = ["ClubChat", "Chats", "Clubs", "Profile"];
//
//     void handleSearch() {
//       context.push("/search");
//     }
//
//     void handleNotifications() {
//       setState(() {
//         unread_notification = 0;
//       });
//       context.push("/notifications");
//     }
//
//     void handleFloatingActionButton() {
//       // Add your floating action button functionality here
//       // For example, create a new event, post, or start a chat
//       showModalBottomSheet(
//         context: context,
//         builder: (BuildContext context) {
//           return Container(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 ListTile(
//                   leading: const Icon(Icons.event),
//                   title: const Text('Create Event'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     // Add navigation to create event
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.post_add),
//                   title: const Text('Create Post'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     // Add navigation to create post
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.chat),
//                   title: const Text('Start Chat'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     // Add navigation to start chat
//                   },
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     }
//
//     final Widget notificationIcon = Stack(
//       children: [
//         const Icon(Icons.notifications),
//         if (unread_notification > 0)
//           Positioned(
//             right: 0,
//             child: Container(
//               padding: const EdgeInsets.all(1),
//               decoration: BoxDecoration(
//                 color: Colors.red,
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               constraints: const BoxConstraints(
//                 minWidth: 12,
//                 minHeight: 12,
//               ),
//               child: Text(
//                 '$unread_notification',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 8,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ),
//       ],
//     );
//
//     // Different app bar actions for each tab
//     final List<List<Widget>> appBarActions = [
//       [ // Home tab actions
//         IconButton(
//           icon: const Icon(Icons.search, color: Colors.black),
//           onPressed: handleSearch,
//         ),
//         IconButton(
//           icon: notificationIcon,
//           onPressed: handleNotifications,
//         ),
//         if (_collegeId != "" && _collegeId != dotenv.env['OTHER_COLLEGE_ID'])
//           IconButton(
//             icon: const Icon(Icons.more_horiz),
//             onPressed: () {
//               var isAdmin =
//               collegeData!.admin.any((item) => item.id == _currentUserId);
//               final BottomSheetCollegeInfo sheetCollegeInfo =
//               BottomSheetCollegeInfo();
//               sheetCollegeInfo.showBottomSheet(
//                   context, collegeData, isAdmin, true);
//             },
//           ),
//         const SizedBox(width: 8)
//       ],
//       [ // Chats tab actions
//         IconButton(
//           icon: const Icon(Icons.search),
//           onPressed: handleSearch,
//         ),
//         IconButton(
//           icon: notificationIcon,
//           onPressed: handleNotifications,
//         ),
//         const SizedBox(width: 8)
//       ],
//       [ // Clubs tab actions
//         IconButton(
//           icon: const Icon(Icons.search),
//           onPressed: handleSearch,
//         ),
//         IconButton(
//           icon: notificationIcon,
//           onPressed: handleNotifications,
//         ),
//         const SizedBox(width: 8)
//       ],
//       [ // Profile tab actions (minimal)
//         const SizedBox(width: 8)
//       ],
//     ];
//
//     return Scaffold(
//       backgroundColor:const Color(0xffF9FAFB),
//       appBar: AppBar(
//         backgroundColor: const Color.fromARGB(255, 211, 232, 255),
//         title: Text(
//           appTitle[_currentIndex],
//           style: const TextStyle(
//             color: Color.fromARGB(255, 56, 114, 220),
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: false,
//         automaticallyImplyLeading: false, // Removes the drawer/hamburger menu
//         actions: appBarActions[_currentIndex],
//       ),
//       body: PageView(
//         controller: _pageController,
//         onPageChanged: (index) {
//           _updateIndex(index);
//         },
//         children: screens,
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: Colors.white,
//         selectedItemColor: const Color.fromARGB(255, 56, 114, 220),
//         unselectedItemColor: Colors.grey,
//         currentIndex: _currentIndex,
//         type: BottomNavigationBarType.fixed,
//         showSelectedLabels: true,
//         showUnselectedLabels: true,
//         items: [
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Stack(
//               children: [
//                 const Icon(Icons.chat_outlined),
//                 if (unread_chat > 0)
//                   Positioned(
//                     right: 0,
//                     top: 0,
//                     child: Container(
//                       padding: const EdgeInsets.all(2),
//                       decoration: BoxDecoration(
//                         color: Colors.red,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       constraints: const BoxConstraints(
//                         minWidth: 16,
//                         minHeight: 16,
//                       ),
//                       child: Text(
//                         '$unread_chat',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 10,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//             label: 'Chats',
//           ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.groups_3_outlined),
//             label: 'Clubs',
//           ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.person_outline),
//             label: 'Profile',
//           ),
//         ],
//         onTap: (index) {
//           _pageController.jumpToPage(index);
//         },
//       ),
//       floatingActionButton: Stack(
//         alignment: Alignment.bottomCenter,
//         children: [
//           AnimatedPositioned(
//             duration: const Duration(milliseconds: 300),
//             bottom: _isFabOpen ? 176.0 : 80.0,
//             right: MediaQuery.of(context).size.width / 2 - 95,
//             child: Visibility(
//               visible: _isFabOpen,
//               child: FloatingActionButton.extended(
//                 heroTag: "clubWorkshop",
//                 onPressed: () {
//                   setState(() {
//                     _isFabOpen = false;
//                   });
//                 },
//                 icon: const Icon(Icons.work,color:Color(0xff1E40AF),),
//                 label:Text("Club Workshop",style:GoogleFonts.poppins(color:const Color(0xff0742A2))),
//                 backgroundColor: const Color(0xffA8C7FB),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//               ),
//             ),
//           ),
//
//           AnimatedPositioned(
//             duration: const Duration(milliseconds: 300),
//             bottom: _isFabOpen ? 110.0 : 80.0,
//             right: MediaQuery.of(context).size.width / 2 - 80,
//             child: Visibility(
//               visible: _isFabOpen,
//               child: FloatingActionButton.extended(
//                 heroTag: "hostEvent",
//                 onPressed: () {
//                   setState(() {
//                     _isFabOpen = false;
//                   });
//                 },
//                 icon: const Icon(Icons.event,color:Color(0xff1E40AF),),
//                 label:Text("Host Event",style:GoogleFonts.poppins(color:const Color(0xff0742A2))),
//                 backgroundColor: const Color(0xffA8C7FB),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 40,
//             right: MediaQuery.of(context).size.width / 2 - 28,
//             child: FloatingActionButton(
//               heroTag: "mainFab",
//               backgroundColor: const Color.fromARGB(255, 56, 114, 220),
//               onPressed: () {
//                 setState(() {
//                   _isFabOpen = !_isFabOpen;
//                 });
//               },
//               child: Icon(_isFabOpen ? Icons.close : Icons.add, color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//     );
//   }
// }
// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names
// import 'dart:io';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:learningx_flutter_app/Screens/club/form/club_form1.dart';
// import 'package:learningx_flutter_app/Screens/college/bottom_sheet_college_info.dart';
// import 'package:learningx_flutter_app/Screens/extra/contact_us.dart';
// import 'package:learningx_flutter_app/Screens/extra/setting_privacy.dart';
// import 'package:learningx_flutter_app/Screens/home/club_feed.dart';
// import 'package:learningx_flutter_app/Screens/home/empty_college_selected.dart';
// import 'package:learningx_flutter_app/Screens/home/event_tab_feed.dart';
// import 'package:learningx_flutter_app/api/common/launch_url.dart';
// import 'package:learningx_flutter_app/api/fcm/notification.dart';
// import 'package:learningx_flutter_app/api/model/college_model.dart';
// import 'package:learningx_flutter_app/api/provider/chat_room_provider.dart';
// import 'package:learningx_flutter_app/api/provider/college_provider.dart';
// import 'package:learningx_flutter_app/api/provider/extra_provider.dart';
// import 'package:learningx_flutter_app/api/provider/notification_provider.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class MyHomePage extends ConsumerStatefulWidget {
//   final int? index;
//   const MyHomePage({super.key, this.index});
//
//   @override
//   ConsumerState<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends ConsumerState<MyHomePage> {
//   int _currentIndex = 0;
//   bool _isLoading = true; // To handle loading state
//   var unread_notification = 0;
//   var unread_chat = 0;
//   var _currentUserId = "";
//   var _currentUserName = "user_name";
//   var _currentUserImg =
//       "https://learningx-s3.s3.ap-south-1.amazonaws.com/user.png";
//   var _collegeId = "";
//   final NotificationSetUp _noti = NotificationSetUp();
//   late final PageController _pageController;
//
//   @override
//   void initState() {
//     super.initState();
//     _initialize();
//   }
//
//   Future<void> _initialize() async {
//     await _loadCurrentUser();
//     setState(() => _isLoading = false);
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await ref
//           .read(selectedCollegeProvider(_collegeId).notifier)
//           .fetchCollege(_collegeId);
//     });
//     // Initialize PageController with widget.index or default to 0
//     _pageController = PageController(initialPage: widget.index ?? 0);
//     _currentIndex = widget.index ?? 0;
//     countUnreadCount();
//     _noti.configurePushNotifications(context);
//     _noti.eventListenerCallback(context);
//   }
//
//   Future<void> _loadCurrentUser() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _currentUserId = prefs.getString('id') ?? "";
//       _currentUserName = prefs.getString('displayName') ?? "";
//       _currentUserImg = prefs.getString("userImg") ?? "";
//       _collegeId = prefs.getString('college') ?? "";
//       _isLoading = false; // Data is fetched, stop loading
//     });
//   }
//
//   void countUnreadCount() async {
//     int chatCount = await countUnreadChatRoomApi();
//     int notiCount = await countUnreadNotificationApi();
//     setState(() {
//       unread_chat = chatCount;
//       unread_notification = notiCount;
//     });
//   }
//
//   void _updateIndex(int index) {
//     _loadCurrentUser();
//     countUnreadCount();
//     setState(() {
//       _currentIndex = index;
//     });
//   }
//
//   Future<void> shareText() async {
//     const String text =
//         "Hey there, you can use the link below to download the app and join the campus clubs in a hassle free way! \nSee you in Campus Clubs.\n\n https://www.clubchat.live/apps";
//     final byteData = await rootBundle.load('assets/images/learningx_icon.png');
//     final tempDir = await getTemporaryDirectory();
//     final file = File('${tempDir.path}/learningx_icon.png');
//     await file.writeAsBytes(byteData.buffer.asUint8List());
//
//     Share.shareXFiles(
//       [XFile(file.path)],
//       text: text,
//       subject: 'Check out this link!',
//     );
//   }
//
//   // Method to create the logout dialog
//   AlertDialog _buildLogoutDialog() {
//     return AlertDialog(
//       title: const Text("Are you sure?"),
//       content: const Text("Do You want to Logout."),
//       actions: [
//         TextButton(
//           child: const Text("Cancel"),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//         TextButton(
//           child: const Text("Logout"),
//           onPressed: () async {
//             await logUserActivityApi(context, {
//               'activityType': "login",
//               'college': _collegeId == "" ? null : _collegeId,
//               'platform': kIsWeb ? "mWeb" : Platform.operatingSystem
//             });
//             final SharedPreferences prefs =
//             await SharedPreferences.getInstance();
//             await prefs.clear();
//
//             final GoogleSignIn googleSignIn = GoogleSignIn();
//             await googleSignIn.signOut();
//
//             String azureId = prefs.getString('azureId') ?? "";
//             if (azureId != "") {
//               final Uri logoutUrl = Uri.parse(
//                   'https://login.microsoftonline.com/common/oauth2/v2.0/logout');
//               await LaunchUrl.openUrl(logoutUrl.toString());
//             }
//             Navigator.of(context).popUntil((route) => route.isFirst);
//             context.go("/");
//           },
//         )
//       ],
//     );
//   }
//
//   // Placeholder for Chats screen
//   Widget _buildChatsScreen() {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.chat_outlined,
//               size: 80,
//               color: Colors.grey.shade400,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Chats',
//               style: TextStyle(
//                 fontSize: 24,
//                 color: Colors.grey.shade600,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Your conversations will appear here',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey.shade500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Profile page widget
//   Widget _buildProfilePage() {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           // Profile header
//           Container(
//             margin: const EdgeInsets.only(top: 32, bottom: 32),
//             child: Center(
//               child: Column(
//                 children: [
//                   GestureDetector(
//                     onTap: () async {
//                       context.push("/profile/$_currentUserId");
//                     },
//                     child: CircleAvatar(
//                       radius: 40,
//                       backgroundImage: NetworkImage(_currentUserImg),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     _currentUserName,
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           // Menu items
//           ListTile(
//             leading: const Icon(Icons.schedule),
//             title: const Text('Upcoming Reminder'),
//             onTap: () {
//               context.push("/reminder");
//             },
//           ),
//           if (_collegeId != "" &&
//               _collegeId != dotenv.env['OTHER_COLLEGE_ID'])
//             ListTile(
//               leading: const Icon(Icons.school_outlined),
//               title: const Text('My Campus'),
//               onTap: () {
//                 context.push("/college/$_collegeId");
//               },
//             ),
//           ListTile(
//             leading: const Icon(Icons.contact_phone),
//             title: const Text('Contact Us'),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const ContactUs()),
//               );
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.settings_outlined),
//             title: const Text('Setting & Privacy'),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) =>
//                         SettingAndPrivacy(id: _currentUserId)),
//               );
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.share),
//             title: const Text('Invite and Share'),
//             onTap: () async {
//               await shareText();
//             },
//           ),
//           if (kIsWeb)
//             ListTile(
//               leading: const Icon(Icons.install_mobile_outlined),
//               title: const Text('Download App'),
//               onTap: () {
//                 context.go("/apps");
//               },
//             ),
//           ListTile(
//             leading: const Icon(Icons.logout),
//             title: const Text('Logout'),
//             onTap: () {
//               showDialog(
//                 context: context,
//                 builder: (BuildContext context) {
//                   return _buildLogoutDialog();
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     College? collegeData;
//     if (_collegeId.isNotEmpty) {
//       collegeData = ref.watch(selectedCollegeProvider(_collegeId));
//     }
//
//     final List<Widget> screens = [
//       EventTabFeed(id: _collegeId), // Home screen
//       _buildChatsScreen(), // Chats screen
//       (_collegeId.isNotEmpty && _collegeId != dotenv.env['OTHER_COLLEGE_ID'])
//           ? const ClubsScreen()
//           : const EmptyCollegeSelected(), // Clubs screen
//       _buildProfilePage(), // Profile screen
//     ];
//
//     final List<String> appTitle = ["ClubChat", "Chats", "Clubs", "Profile"];
//
//     void handleSearch() {
//       context.push("/search");
//     }
//
//     void handleNotifications() {
//       setState(() {
//         unread_notification = 0;
//       });
//       context.push("/notifications");
//     }
//
//     void handleFloatingActionButton() {
//       showModalBottomSheet(
//         context: context,
//         builder: (BuildContext context) {
//           return Container(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 ListTile(
//                   leading: const Icon(Icons.event),
//                   title: const Text('Events'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     showDialog(
//                       context: context,
//                       builder: (BuildContext context) {
//                         return Dialog(
//                           backgroundColor: Colors.transparent,
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               buildEventOption(
//                                 icon: Icons.school,
//                                 label: 'Club Workshop',
//                                 onTap: () {
//                                   Navigator.pop(context);
//                                   Navigator.push(context,MaterialPageRoute(builder:(context)=>const ClubForm1Activity()));
//                                 },
//                               ),
//                               const SizedBox(height: 10),
//                               buildEventOption(
//                                 icon: Icons.event,
//                                 label: 'Host Event',
//                                 onTap: () {
//                                   Navigator.pop(context);
//                                 },
//                               ),
//                               const SizedBox(height: 20),
//                               FloatingActionButton(
//                                 onPressed: () {
//                                   Navigator.pop(context);
//                                 },
//                                 backgroundColor: const Color(0xFF3872DC),
//                                 child: const Icon(Icons.close, color: Colors.white),
//                               ),
//                               const SizedBox(height: 20),
//                             ],
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.post_add),
//                   title: const Text('Clubs'),
//                   onTap: () {
//                     Navigator.pop(context);
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.chat),
//                   title: const Text('Fests'),
//                   onTap: () {
//                     Navigator.pop(context);
//                   },
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     }
//
//     final Widget notificationIcon = Stack(
//       children: [
//         const Icon(Icons.notifications),
//         if (unread_notification > 0)
//           Positioned(
//             right: 0,
//             child: Container(
//               padding: const EdgeInsets.all(1),
//               decoration: BoxDecoration(
//                 color: Colors.red,
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               constraints: const BoxConstraints(
//                 minWidth: 12,
//                 minHeight: 12,
//               ),
//               child: Text(
//                 '$unread_notification',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 8,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ),
//       ],
//     );
//
//     final List<List<Widget>> appBarActions = [
//       [ // Home tab actions
//         IconButton(
//           icon: const Icon(Icons.search, color: Colors.black),
//           onPressed: handleSearch,
//         ),
//         IconButton(
//           icon: notificationIcon,
//           onPressed: handleNotifications,
//         ),
//         if (_collegeId != "" && _collegeId != dotenv.env['OTHER_COLLEGE_ID'])
//           IconButton(
//             icon: const Icon(Icons.more_horiz),
//             onPressed: () {
//               var isAdmin =
//               collegeData!.admin.any((item) => item.id == _currentUserId);
//               final BottomSheetCollegeInfo sheetCollegeInfo =
//               BottomSheetCollegeInfo();
//               sheetCollegeInfo.showBottomSheet(
//                   context, collegeData, isAdmin, true);
//             },
//           ),
//         const SizedBox(width: 8)
//       ],
//       [ // Chats tab actions
//         IconButton(
//           icon: const Icon(Icons.search),
//           onPressed: handleSearch,
//         ),
//         IconButton(
//           icon: notificationIcon,
//           onPressed: handleNotifications,
//         ),
//         const SizedBox(width: 8)
//       ],
//       [ // Clubs tab actions
//         IconButton(
//           icon: const Icon(Icons.search),
//           onPressed: handleSearch,
//         ),
//         IconButton(
//           icon: notificationIcon,
//           onPressed: handleNotifications,
//         ),
//         const SizedBox(width: 8)
//       ],
//       [ // Profile tab actions (minimal)
//         const SizedBox(width: 8)
//       ],
//     ];
//
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color.fromARGB(255, 211, 232, 255),
//         title: Text(
//           appTitle[_currentIndex],
//           style: const TextStyle(
//             color: Color.fromARGB(255, 56, 114, 220),
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: false,
//         automaticallyImplyLeading: false, // Removes the drawer/hamburger menu
//         actions: appBarActions[_currentIndex],
//       ),
//       body: PageView(
//         controller: _pageController,
//         onPageChanged: (index) {
//           _updateIndex(index);
//         },
//         children: screens,
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: Colors.white,
//         selectedItemColor: const Color.fromARGB(255, 56, 114, 220),
//         unselectedItemColor: Colors.grey,
//         currentIndex: _currentIndex,
//         type: BottomNavigationBarType.fixed,
//         showSelectedLabels: true,
//         showUnselectedLabels: true,
//         items: [
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Stack(
//               children: [
//                 const Icon(Icons.chat_outlined),
//                 if (unread_chat > 0)
//                   Positioned(
//                     right: 0,
//                     top: 0,
//                     child: Container(
//                       padding: const EdgeInsets.all(2),
//                       decoration: BoxDecoration(
//                         color: Colors.red,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       constraints: const BoxConstraints(
//                         minWidth: 16,
//                         minHeight: 16,
//                       ),
//                       child: Text(
//                         '$unread_chat',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 10,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//             label: 'Chats',
//           ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.groups_3_outlined),
//             label: 'Clubs',
//           ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.person_outline),
//             label: 'Profile',
//           ),
//         ],
//         onTap: (index) {
//           _pageController.jumpToPage(index);
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: handleFloatingActionButton,
//         backgroundColor: const Color.fromARGB(255, 56, 114, 220),
//         child: const Icon(
//           Icons.add,
//           color: Colors.white,
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//     );
//   }
//
//   Widget buildEventOption({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//         decoration: BoxDecoration(
//           color: const Color(0xFFE4EDFD),
//           borderRadius: BorderRadius.circular(30),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 8,
//               offset: const Offset(0, 4),
//             )
//           ],
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, color: const Color(0xFF3872DC)),
//             const SizedBox(width: 10),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 16,
//                 color: Color(0xFF3872DC),
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names
// import 'dart:io';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:learningx_flutter_app/Screens/home/chat_tab_screen.dart';
// import 'package:learningx_flutter_app/Screens/college/bottom_sheet_college_info.dart';
// import 'package:learningx_flutter_app/Screens/extra/contact_us.dart';
// import 'package:learningx_flutter_app/Screens/extra/setting_privacy.dart';
// import 'package:learningx_flutter_app/Screens/home/club_feed.dart';
// import 'package:learningx_flutter_app/Screens/home/empty_college_selected.dart';
// import 'package:learningx_flutter_app/Screens/home/event_tab_feed.dart';
// import 'package:learningx_flutter_app/api/common/launch_url.dart';
// import 'package:learningx_flutter_app/api/fcm/notification.dart';
// import 'package:learningx_flutter_app/api/model/college_model.dart';
// import 'package:learningx_flutter_app/api/provider/chat_room_provider.dart';
// import 'package:learningx_flutter_app/api/provider/college_provider.dart';
// import 'package:learningx_flutter_app/api/provider/extra_provider.dart';
// import 'package:learningx_flutter_app/api/provider/notification_provider.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:learningx_flutter_app/Screens/chats/chat_room_item.dart';
//
// import '../club/form/club_form1.dart';
//
//
// class MyHomePage extends ConsumerStatefulWidget {
//   final int? index;
//   const MyHomePage({super.key, this.index});
//
//   @override
//   ConsumerState<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends ConsumerState<MyHomePage> {
//   int _currentIndex = 0;
//   bool _isLoading = true; // To handle loading state
//   var unread_notification = 0;
//   var unread_chat = 0;
//   var _currentUserId = "";
//   var _currentUserName = "user_name";
//   var _currentUserImg =
//       "https://learningx-s3.s3.ap-south-1.amazonaws.com/user.png";
//   var _collegeId = "";
//   final NotificationSetUp _noti = NotificationSetUp();
//   late final PageController _pageController;
//
//   @override
//   void initState() {
//     super.initState();
//     _initialize();
//   }
//
//   Future<void> _initialize() async {
//     await _loadCurrentUser();
//     setState(() => _isLoading = false);
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await ref
//           .read(selectedCollegeProvider(_collegeId).notifier)
//           .fetchCollege(_collegeId);
//     });
//     // Initialize PageController with widget.index or default to 0
//     _pageController = PageController(initialPage: widget.index ?? 0);
//     _currentIndex = widget.index ?? 0;
//     countUnreadCount();
//     _noti.configurePushNotifications(context);
//     _noti.eventListenerCallback(context);
//   }
//
//   Future<void> _loadCurrentUser() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _currentUserId = prefs.getString('id') ?? "";
//       _currentUserName = prefs.getString('displayName') ?? "";
//       _currentUserImg = prefs.getString("userImg") ?? "";
//       _collegeId = prefs.getString('college') ?? "";
//       _isLoading = false; // Data is fetched, stop loading
//     });
//   }
//
//   void countUnreadCount() async {
//     int chatCount = await countUnreadChatRoomApi();
//     int notiCount = await countUnreadNotificationApi();
//     setState(() {
//       unread_chat = chatCount;
//       unread_notification = notiCount;
//     });
//   }
//
//   void _updateIndex(int index) {
//     _loadCurrentUser();
//     countUnreadCount();
//     setState(() {
//       _currentIndex = index;
//     });
//   }
//
//   Future<void> shareText() async {
//     const String text =
//         "Hey there, you can use the link below to download the app and join the campus clubs in a hassle free way! \nSee you in Campus Clubs.\n\n https://www.clubchat.live/apps";
//     final byteData = await rootBundle.load('assets/images/learningx_icon.png');
//     final tempDir = await getTemporaryDirectory();
//     final file = File('${tempDir.path}/learningx_icon.png');
//     await file.writeAsBytes(byteData.buffer.asUint8List());
//
//     Share.shareXFiles(
//       [XFile(file.path)],
//       text: text,
//       subject: 'Check out this link!',
//     );
//   }
//
//   // Method to create the logout dialog
//   AlertDialog _buildLogoutDialog() {
//     return AlertDialog(
//       title: const Text("Are you sure?"),
//       content: const Text("Do You want to Logout."),
//       actions: [
//         TextButton(
//           child: const Text("Cancel"),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//         TextButton(
//           child: const Text("Logout"),
//           onPressed: () async {
//             await logUserActivityApi(context, {
//               'activityType': "login",
//               'college': _collegeId == "" ? null : _collegeId,
//               'platform': kIsWeb ? "mWeb" : Platform.operatingSystem
//             });
//             final SharedPreferences prefs =
//             await SharedPreferences.getInstance();
//             await prefs.clear();
//
//             final GoogleSignIn googleSignIn = GoogleSignIn();
//             await googleSignIn.signOut();
//
//             String azureId = prefs.getString('azureId') ?? "";
//             if (azureId != "") {
//               final Uri logoutUrl = Uri.parse(
//                   'https://login.microsoftonline.com/common/oauth2/v2.0/logout');
//               await LaunchUrl.openUrl(logoutUrl.toString());
//             }
//             Navigator.of(context).popUntil((route) => route.isFirst);
//             context.go("/");
//           },
//         )
//       ],
//     );
//   }
//
//
//
//   // Profile page widget
//   Widget _buildProfilePage() {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           // Profile header
//           Container(
//             margin: const EdgeInsets.only(top: 32, bottom: 32),
//             child: Center(
//               child: Column(
//                 children: [
//                   GestureDetector(
//                     onTap: () async {
//                       context.push("/profile/$_currentUserId");
//                     },
//                     child: CircleAvatar(
//                       radius: 40,
//                       backgroundImage: NetworkImage(_currentUserImg),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     _currentUserName,
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           // Menu items
//           ListTile(
//             leading: const Icon(Icons.schedule),
//             title: const Text('Upcoming Reminder'),
//             onTap: () {
//               context.push("/reminder");
//             },
//           ),
//           if (_collegeId != "" &&
//               _collegeId != dotenv.env['OTHER_COLLEGE_ID'])
//             ListTile(
//               leading: const Icon(Icons.school_outlined),
//               title: const Text('My Campus'),
//               onTap: () {
//                 context.push("/college/$_collegeId");
//               },
//             ),
//           ListTile(
//             leading: const Icon(Icons.contact_phone),
//             title: const Text('Contact Us'),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const ContactUs()),
//               );
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.settings_outlined),
//             title: const Text('Setting & Privacy'),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) =>
//                         SettingAndPrivacy(id: _currentUserId)),
//               );
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.share),
//             title: const Text('Invite and Share'),
//             onTap: () async {
//               await shareText();
//             },
//           ),
//           if (kIsWeb)
//             ListTile(
//               leading: const Icon(Icons.install_mobile_outlined),
//               title: const Text('Download App'),
//               onTap: () {
//                 context.go("/apps");
//               },
//             ),
//           ListTile(
//             leading: const Icon(Icons.logout),
//             title: const Text('Logout'),
//             onTap: () {
//               showDialog(
//                 context: context,
//                 builder: (BuildContext context) {
//                   return _buildLogoutDialog();
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     College? collegeData;
//     if (_collegeId.isNotEmpty) {
//       collegeData = ref.watch(selectedCollegeProvider(_collegeId));
//     }
//
//     final List<Widget> screens = [
//       EventTabFeed(id: _collegeId),
//       const ChatTabScreen(),
//       (_collegeId.isNotEmpty && _collegeId != dotenv.env['OTHER_COLLEGE_ID'])
//           ? const ClubsScreen()
//           : const EmptyCollegeSelected(),
//       _buildProfilePage(),
//     ];
//
//     final List<String> appTitle = ["ClubChat", "Chats", "Clubs", "Profile"];
//
//     void handleSearch() {
//       context.push("/search");
//     }
//
//     void handleNotifications() {
//       setState(() {
//         unread_notification = 0;
//       });
//       context.push("/notifications");
//     }
//     void handleFloatingActionButton() {
//       showModalBottomSheet(
//         context: context,
//         builder: (BuildContext context) {
//           return Container(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 ListTile(
//                   leading: const Icon(Icons.event),
//                   title: const Text('Events'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     showDialog(
//                       context: context,
//                       builder: (BuildContext context) {
//                         return Dialog(
//                           backgroundColor: Colors.transparent,
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               buildEventOption(
//                                 icon: Icons.school,
//                                 label: 'Club Workshop',
//                                 onTap: () {
//                                   Navigator.pop(context);
//                                   Navigator.push(context,MaterialPageRoute(builder:(context)=>const ClubForm1Activity()));
//                                 },
//                               ),
//                               const SizedBox(height: 10),
//                               buildEventOption(
//                                 icon: Icons.event,
//                                 label: 'Host Event',
//                                 onTap: () {
//                                   Navigator.pop(context);
//                                 },
//                               ),
//                               const SizedBox(height: 20),
//                               FloatingActionButton(
//                                 onPressed: () {
//                                   Navigator.pop(context);
//                                 },
//                                 backgroundColor: const Color(0xFF3872DC),
//                                 child: const Icon(Icons.close, color: Colors.white),
//                               ),
//                               const SizedBox(height: 20),
//                             ],
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.post_add),
//                   title: const Text('Clubs'),
//                   onTap: () {
//                     Navigator.pop(context);
//
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.chat),
//                   title: const Text('Fests'),
//                   onTap: () {
//                     Navigator.pop(context);
//                   },
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     }
//
//     final Widget notificationIcon = Stack(
//       children: [
//         const Icon(Icons.notifications),
//         if (unread_notification > 0)
//           Positioned(
//             right: 0,
//             child: Container(
//               padding: const EdgeInsets.all(1),
//               decoration: BoxDecoration(
//                 color: Colors.red,
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               constraints: const BoxConstraints(
//                 minWidth: 12,
//                 minHeight: 12,
//               ),
//               child: Text(
//                 '$unread_notification',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 8,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ),
//       ],
//     );
//
//     // Different app bar actions for each tab
//     final List<List<Widget>> appBarActions = [
//       [ // Home tab actions
//         IconButton(
//           icon: const Icon(Icons.search, color: Colors.black),
//           onPressed: handleSearch,
//         ),
//         IconButton(
//           icon: notificationIcon,
//           onPressed: handleNotifications,
//         ),
//         if (_collegeId != "" && _collegeId != dotenv.env['OTHER_COLLEGE_ID'])
//           IconButton(
//             icon: const Icon(Icons.more_horiz),
//             onPressed: () {
//               var isAdmin =
//               collegeData!.admin.any((item) => item.id == _currentUserId);
//               final BottomSheetCollegeInfo sheetCollegeInfo =
//               BottomSheetCollegeInfo();
//               sheetCollegeInfo.showBottomSheet(
//                   context, collegeData, isAdmin, true);
//             },
//           ),
//         const SizedBox(width: 8)
//       ],
//       [ // Chats tab actions
//         IconButton(
//           icon: const Icon(Icons.search),
//           onPressed: handleSearch,
//         ),
//         IconButton(
//           icon: notificationIcon,
//           onPressed: handleNotifications,
//         ),
//         const SizedBox(width: 8)
//       ],
//       [ // Clubs tab actions
//         IconButton(
//           icon: const Icon(Icons.search),
//           onPressed: handleSearch,
//         ),
//         IconButton(
//           icon: notificationIcon,
//           onPressed: handleNotifications,
//         ),
//         const SizedBox(width: 8)
//       ],
//       [ // Profile tab actions (minimal)
//         const SizedBox(width: 8)
//       ],
//     ];
//
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color.fromARGB(255, 211, 232, 255),
//         title: Text(
//           appTitle[_currentIndex],
//           style: const TextStyle(
//             color: Color.fromARGB(255, 56, 114, 220),
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: false,
//         automaticallyImplyLeading: false, // Removes the drawer/hamburger menu
//         actions: appBarActions[_currentIndex],
//       ),
//       body: PageView(
//         controller: _pageController,
//         onPageChanged: (index) {
//           _updateIndex(index);
//         },
//         children: screens,
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: Colors.white,
//         selectedItemColor: const Color.fromARGB(255, 56, 114, 220),
//         unselectedItemColor: Colors.grey,
//         currentIndex: _currentIndex,
//         type: BottomNavigationBarType.fixed,
//         showSelectedLabels: true,
//         showUnselectedLabels: true,
//         items: [
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Stack(
//               children: [
//                 const Icon(Icons.chat_outlined),
//                 if (unread_chat > 0)
//                   Positioned(
//                     right: 0,
//                     top: 0,
//                     child: Container(
//                       padding: const EdgeInsets.all(2),
//                       decoration: BoxDecoration(
//                         color: Colors.red,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       constraints: const BoxConstraints(
//                         minWidth: 16,
//                         minHeight: 16,
//                       ),
//                       child: Text(
//                         '$unread_chat',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 10,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//             label: 'Chats',
//           ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.groups_3_outlined),
//             label: 'Clubs',
//           ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.person_outline),
//             label: 'Profile',
//           ),
//         ],
//         onTap: (index) {
//           _pageController.jumpToPage(index);
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: handleFloatingActionButton,
//         backgroundColor: const Color.fromARGB(255, 56, 114, 220),
//         child: const Icon(
//           Icons.add,
//           color: Colors.white,
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//     );
//   }
//   Widget buildEventOption({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//         decoration: BoxDecoration(
//           color: const Color(0xFFE4EDFD),
//           borderRadius: BorderRadius.circular(30),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 8,
//               offset: const Offset(0, 4),
//             )
//           ],
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, color: const Color(0xFF3872DC)),
//             const SizedBox(width: 10),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 16,
//                 color: Color(0xFF3872DC),
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names
// import 'dart:io';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:learningx_flutter_app/Screens/home/chat_tab_screen.dart';
// import 'package:learningx_flutter_app/Screens/college/bottom_sheet_college_info.dart';
// import 'package:learningx_flutter_app/Screens/extra/contact_us.dart';
// import 'package:learningx_flutter_app/Screens/extra/setting_privacy.dart';
// import 'package:learningx_flutter_app/Screens/home/club_feed.dart';
// import 'package:learningx_flutter_app/Screens/home/empty_college_selected.dart';
// import 'package:learningx_flutter_app/Screens/home/event_tab_feed.dart';
// import 'package:learningx_flutter_app/api/common/launch_url.dart';
// import 'package:learningx_flutter_app/api/fcm/notification.dart';
// import 'package:learningx_flutter_app/api/model/college_model.dart';
// import 'package:learningx_flutter_app/api/provider/chat_room_provider.dart';
// import 'package:learningx_flutter_app/api/provider/college_provider.dart';
// import 'package:learningx_flutter_app/api/provider/extra_provider.dart';
// import 'package:learningx_flutter_app/api/provider/notification_provider.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:learningx_flutter_app/Screens/chats/chat_room_item.dart';
// import '../club/form/club_form1.dart';
//
//
// class MyHomePage extends ConsumerStatefulWidget {
//   final int? index;
//   const MyHomePage({super.key, this.index});
//
//   @override
//   ConsumerState<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends ConsumerState<MyHomePage> {
//   int _currentIndex = 0;
//   bool _isLoading = true; // To handle loading state
//   var unread_notification = 0;
//   var unread_chat = 0;
//   var _currentUserId = "";
//   var _currentUserName = "user_name";
//   var _currentUserImg =
//       "https://learningx-s3.s3.ap-south-1.amazonaws.com/user.png";
//   var _collegeId = "";
//   final NotificationSetUp _noti = NotificationSetUp();
//   late final PageController _pageController;
//
//   @override
//   void initState() {
//     super.initState();
//     _initialize();
//   }
//
//   Future<void> _initialize() async {
//     await _loadCurrentUser();
//     setState(() => _isLoading = false);
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await ref
//           .read(selectedCollegeProvider(_collegeId).notifier)
//           .fetchCollege(_collegeId);
//     });
//     // Initialize PageController with widget.index or default to 0
//     _pageController = PageController(initialPage: widget.index ?? 0);
//     _currentIndex = widget.index ?? 0;
//     countUnreadCount();
//     _noti.configurePushNotifications(context);
//     _noti.eventListenerCallback(context);
//   }
//
//   Future<void> _loadCurrentUser() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _currentUserId = prefs.getString('id') ?? "";
//       _currentUserName = prefs.getString('displayName') ?? "";
//       _currentUserImg = prefs.getString("userImg") ?? "";
//       _collegeId = prefs.getString('college') ?? "";
//       _isLoading = false; // Data is fetched, stop loading
//     });
//   }
//
//   void countUnreadCount() async {
//     int chatCount = await countUnreadChatRoomApi();
//     int notiCount = await countUnreadNotificationApi();
//     setState(() {
//       unread_chat = chatCount;
//       unread_notification = notiCount;
//     });
//   }
//
//   void _updateIndex(int index) {
//     _loadCurrentUser();
//     countUnreadCount();
//     setState(() {
//       _currentIndex = index;
//     });
//   }
//
//   Future<void> shareText() async {
//     const String text =
//         "Hey there, you can use the link below to download the app and join the campus clubs in a hassle free way! \nSee you in Campus Clubs.\n\n https://www.clubchat.live/apps";
//     final byteData = await rootBundle.load('assets/images/learningx_icon.png');
//     final tempDir = await getTemporaryDirectory();
//     final file = File('${tempDir.path}/learningx_icon.png');
//     await file.writeAsBytes(byteData.buffer.asUint8List());
//
//     Share.shareXFiles(
//       [XFile(file.path)],
//       text: text,
//       subject: 'Check out this link!',
//     );
//   }
//
//   // Method to create the logout dialog
//   AlertDialog _buildLogoutDialog() {
//     return AlertDialog(
//       title: const Text("Are you sure?"),
//       content: const Text("Do You want to Logout."),
//       actions: [
//         TextButton(
//           child: const Text("Cancel"),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//         TextButton(
//           child: const Text("Logout"),
//           onPressed: () async {
//             await logUserActivityApi(context, {
//               'activityType': "login",
//               'college': _collegeId == "" ? null : _collegeId,
//               'platform': kIsWeb ? "mWeb" : Platform.operatingSystem
//             });
//             final SharedPreferences prefs =
//             await SharedPreferences.getInstance();
//             await prefs.clear();
//
//             final GoogleSignIn googleSignIn = GoogleSignIn();
//             await googleSignIn.signOut();
//
//             String azureId = prefs.getString('azureId') ?? "";
//             if (azureId != "") {
//               final Uri logoutUrl = Uri.parse(
//                   'https://login.microsoftonline.com/common/oauth2/v2.0/logout');
//               await LaunchUrl.openUrl(logoutUrl.toString());
//             }
//             Navigator.of(context).popUntil((route) => route.isFirst);
//             context.go("/");
//           },
//         )
//       ],
//     );
//   }
//
//
//
//   // Profile page widget
//   Widget _buildProfilePage() {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           // Profile header
//           Container(
//             margin: const EdgeInsets.only(top: 32, bottom: 32),
//             child: Center(
//               child: Column(
//                 children: [
//                   GestureDetector(
//                     onTap: () async {
//                       context.push("/profile/$_currentUserId");
//                     },
//                     child: CircleAvatar(
//                       radius: 40,
//                       backgroundImage: NetworkImage(_currentUserImg),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     _currentUserName,
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           // Menu items
//           ListTile(
//             leading: const Icon(Icons.schedule),
//             title: const Text('Upcoming Reminder'),
//             onTap: () {
//               context.push("/reminder");
//             },
//           ),
//           if (_collegeId != "" &&
//               _collegeId != dotenv.env['OTHER_COLLEGE_ID'])
//             ListTile(
//               leading: const Icon(Icons.school_outlined),
//               title: const Text('My Campus'),
//               onTap: () {
//                 context.push("/college/$_collegeId");
//               },
//             ),
//           ListTile(
//             leading: const Icon(Icons.contact_phone),
//             title: const Text('Contact Us'),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const ContactUs()),
//               );
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.settings_outlined),
//             title: const Text('Setting & Privacy'),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) =>
//                         SettingAndPrivacy(id: _currentUserId)),
//               );
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.share),
//             title: const Text('Invite and Share'),
//             onTap: () async {
//               await shareText();
//             },
//           ),
//           if (kIsWeb)
//             ListTile(
//               leading: const Icon(Icons.install_mobile_outlined),
//               title: const Text('Download App'),
//               onTap: () {
//                 context.go("/apps");
//               },
//             ),
//           ListTile(
//             leading: const Icon(Icons.logout),
//             title: const Text('Logout'),
//             onTap: () {
//               showDialog(
//                 context: context,
//                 builder: (BuildContext context) {
//                   return _buildLogoutDialog();
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     College? collegeData;
//     if (_collegeId.isNotEmpty) {
//       collegeData = ref.watch(selectedCollegeProvider(_collegeId));
//     }
//
//     final List<Widget> screens = [
//       EventTabFeed(id: _collegeId),
//       const ChatTabScreen(),
//       (_collegeId.isNotEmpty && _collegeId != dotenv.env['OTHER_COLLEGE_ID'])
//           ? const ClubsScreen()
//           : const EmptyCollegeSelected(),
//       _buildProfilePage(),
//     ];
//
//     final List<String> appTitle = ["ClubChat", "Chats", "Clubs", "Profile"];
//
//     void handleSearch() {
//       context.push("/search");
//     }
//
//     void handleNotifications() {
//       setState(() {
//         unread_notification = 0;
//       });
//       context.push("/notifications");
//     }
//     void handleFloatingActionButton() {
//       showModalBottomSheet(
//         context: context,
//         builder: (BuildContext context) {
//           return Container(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 ListTile(
//                   leading: const Icon(Icons.event),
//                   title: const Text('Events'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     showDialog(
//                       context: context,
//                       builder: (BuildContext context) {
//                         return Dialog(
//                           backgroundColor: Colors.transparent,
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               buildEventOption(
//                                 icon: Icons.school,
//                                 label: 'Club Workshop',
//                                 onTap: () {
//                                   Navigator.pop(context);
//                                   Navigator.push(context,MaterialPageRoute(builder:(context)=>const ClubForm1Activity()));
//                                 },
//                               ),
//                               const SizedBox(height: 10),
//                               buildEventOption(
//                                 icon: Icons.event,
//                                 label: 'Host Event',
//                                 onTap: () {
//                                   Navigator.pop(context);
//                                 },
//                               ),
//                               const SizedBox(height: 20),
//                               FloatingActionButton(
//                                 onPressed: () {
//                                   Navigator.pop(context);
//                                 },
//                                 backgroundColor: const Color(0xFF3872DC),
//                                 child: const Icon(Icons.close, color: Colors.white),
//                               ),
//                               const SizedBox(height: 20),
//                             ],
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.post_add),
//                   title: const Text('Clubs'),
//                   onTap: () {
//                     Navigator.pop(context);
//
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.chat),
//                   title: const Text('Fests'),
//                   onTap: () {
//                     Navigator.pop(context);
//                   },
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     }
//
//     final Widget notificationIcon = Stack(
//       children: [
//         const Icon(Icons.notifications),
//         if (unread_notification > 0)
//           Positioned(
//             right: 0,
//             child: Container(
//               padding: const EdgeInsets.all(1),
//               decoration: BoxDecoration(
//                 color: Colors.red,
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               constraints: const BoxConstraints(
//                 minWidth: 12,
//                 minHeight: 12,
//               ),
//               child: Text(
//                 '$unread_notification',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 8,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ),
//       ],
//     );
//
//     // Different app bar actions for each tab
//     final List<List<Widget>> appBarActions = [
//       [ // Home tab actions
//         IconButton(
//           icon: const Icon(Icons.search, color: Colors.black),
//           onPressed: handleSearch,
//         ),
//         IconButton(
//           icon: notificationIcon,
//           onPressed: handleNotifications,
//         ),
//         if (_collegeId != "" && _collegeId != dotenv.env['OTHER_COLLEGE_ID'])
//           IconButton(
//             icon: const Icon(Icons.more_horiz),
//             onPressed: () {
//               var isAdmin =
//               collegeData!.admin.any((item) => item.id == _currentUserId);
//               final BottomSheetCollegeInfo sheetCollegeInfo =
//               BottomSheetCollegeInfo();
//               sheetCollegeInfo.showBottomSheet(
//                   context, collegeData, isAdmin, true);
//             },
//           ),
//         const SizedBox(width: 8)
//       ],
//       [ // Chats tab actions
//         IconButton(
//           icon: const Icon(Icons.search),
//           onPressed: handleSearch,
//         ),
//         IconButton(
//           icon: notificationIcon,
//           onPressed: handleNotifications,
//         ),
//         const SizedBox(width: 8)
//       ],
//       [ // Clubs tab actions
//         IconButton(
//           icon: const Icon(Icons.search),
//           onPressed: handleSearch,
//         ),
//         IconButton(
//           icon: notificationIcon,
//           onPressed: handleNotifications,
//         ),
//         const SizedBox(width: 8)
//       ],
//       [ // Profile tab actions (minimal)
//         const SizedBox(width: 8)
//       ],
//     ];
//
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color.fromARGB(255, 211, 232, 255),
//         title: Text(
//           appTitle[_currentIndex],
//           style: const TextStyle(
//             color: Color.fromARGB(255, 56, 114, 220),
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: false,
//         automaticallyImplyLeading: false, // Removes the drawer/hamburger menu
//         actions: appBarActions[_currentIndex],
//       ),
//       body: PageView(
//         controller: _pageController,
//         onPageChanged: (index) {
//           _updateIndex(index);
//         },
//         children: screens,
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: Colors.white,
//         selectedItemColor: const Color.fromARGB(255, 56, 114, 220),
//         unselectedItemColor: Colors.grey,
//         currentIndex: _currentIndex,
//         type: BottomNavigationBarType.fixed,
//         showSelectedLabels: true,
//         showUnselectedLabels: true,
//         items: [
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Stack(
//               children: [
//                 const Icon(Icons.chat_outlined),
//                 if (unread_chat > 0)
//                   Positioned(
//                     right: 0,
//                     top: 0,
//                     child: Container(
//                       padding: const EdgeInsets.all(2),
//                       decoration: BoxDecoration(
//                         color: Colors.red,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       constraints: const BoxConstraints(
//                         minWidth: 16,
//                         minHeight: 16,
//                       ),
//                       child: Text(
//                         '$unread_chat',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 10,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//             label: 'Chats',
//           ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.groups_3_outlined),
//             label: 'Clubs',
//           ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.person_outline),
//             label: 'Profile',
//           ),
//         ],
//         onTap: (index) {
//           _pageController.jumpToPage(index);
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: handleFloatingActionButton,
//         backgroundColor: const Color.fromARGB(255, 56, 114, 220),
//         child: const Icon(
//           Icons.add,
//           color: Colors.white,
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//     );
//   }
//   Widget buildEventOption({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//         decoration: BoxDecoration(
//           color: const Color(0xFFE4EDFD),
//           borderRadius: BorderRadius.circular(30),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 8,
//               offset: const Offset(0, 4),
//             )
//           ],
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, color: const Color(0xFF3872DC)),
//             const SizedBox(width: 10),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 16,
//                 color: Color(0xFF3872DC),
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names
import 'dart:io';

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


class MyHomePage extends ConsumerStatefulWidget {
  final int? index;
  const MyHomePage({super.key, this.index});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
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



  // Profile page widget
  Widget _buildProfilePage() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile header
          Container(
            margin: const EdgeInsets.only(top: 32, bottom: 32),
            child: Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      context.push("/profile/$_currentUserId");
                    },
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(_currentUserImg),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentUserName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Menu items
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Upcoming Reminder'),
            onTap: () {
              context.push("/reminder");
            },
          ),
          if (_collegeId != "" &&
              _collegeId != dotenv.env['OTHER_COLLEGE_ID'])
            ListTile(
              leading: const Icon(Icons.school_outlined),
              title: const Text('My Campus'),
              onTap: () {
                context.push("/college/$_collegeId");
              },
            ),
          ListTile(
            leading: const Icon(Icons.contact_phone),
            title: const Text('Contact Us'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContactUs()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Setting & Privacy'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        SettingAndPrivacy(id: _currentUserId)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Invite and Share'),
            onTap: () async {
              await shareText();
            },
          ),
          if (kIsWeb)
            ListTile(
              leading: const Icon(Icons.install_mobile_outlined),
              title: const Text('Download App'),
              onTap: () {
                context.go("/apps");
              },
            ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return _buildLogoutDialog();
                },
              );
            },
          ),
        ],
      ),
    );
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
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.event),
                  title: const Text('Events'),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          backgroundColor: Colors.transparent,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              buildEventOption(
                                icon: Icons.school,
                                label: 'Club Workshop',
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(context,MaterialPageRoute(builder:(context)=>const ClubForm1Activity()));
                                },
                              ),
                              const SizedBox(height: 10),
                              buildEventOption(
                                icon: Icons.event,
                                label: 'Host Event',
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(context,MaterialPageRoute(builder:(context)=>const ClubForm1Activity()));
                                },
                              ),
                              const SizedBox(height: 20),
                              FloatingActionButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                backgroundColor: const Color(0xFF3872DC),
                                child: const Icon(Icons.close, color: Colors.white),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.post_add),
                  title: const Text('Clubs'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context,MaterialPageRoute(builder:(context)=>const ClubForm1Activity()));

                  },
                ),
                ListTile(
                  leading: const Icon(Icons.chat),
                  title: const Text('Fests'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context,MaterialPageRoute(builder:(context)=>const ClubForm1Activity()));
                  },
                ),
              ],
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

    // Different app bar actions for each tab
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
        if (_collegeId != "" && _collegeId != dotenv.env['OTHER_COLLEGE_ID'])
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
      [ // Chats tab actions
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
      [ // Clubs tab actions
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
      [ // Profile tab actions (minimal)
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
        automaticallyImplyLeading: false, // Removes the drawer/hamburger menu
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
  Widget buildEventOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFE4EDFD),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF3872DC)),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF3872DC),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}