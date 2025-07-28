// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:learningx_flutter_app/Screens/chats/chat_page.dart';
// import 'package:learningx_flutter_app/Screens/club/club_fragment_page.dart';
// import 'package:learningx_flutter_app/Screens/common/report_form.dart';
// import 'package:learningx_flutter_app/Screens/event/event_fragment_page.dart';
// import 'package:learningx_flutter_app/Screens/profile/bottom_sheet_profile_info.dart';
// import 'package:learningx_flutter_app/Screens/profile/profile_form.dart';
// import 'package:learningx_flutter_app/api/model/chat_room_model.dart';
// import 'package:learningx_flutter_app/api/model/post_model.dart';
// import 'package:learningx_flutter_app/api/model/profile_model.dart';
// import 'package:learningx_flutter_app/api/model/user_modal.dart';
// import 'package:learningx_flutter_app/api/provider/chat_room_provider.dart';
// import 'package:learningx_flutter_app/api/provider/profile_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class ProfileActivity extends ConsumerStatefulWidget {
//   final String id;
//   const ProfileActivity({super.key, required this.id});
//
//   @override
//   ConsumerState<ProfileActivity> createState() => _ProfileActivityState();
// }
//
// class _ProfileActivityState extends ConsumerState<ProfileActivity> {
//   int _selectedFragmentIndex = 0;
//   String _currentUserId = "";
//   var _currentFirstname = "user";
//   var _currentLastname = "_name";
//   var _currentUserName = "user_name";
//   var _currentUserImg = "";
//
//   @override
//   void initState() {
//     _loadCurrentUser();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _refresh();
//     });
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
//
//   _loadCurrentUser() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _currentUserId = prefs.getString("id") ?? "";
//       _currentFirstname = prefs.getString("firstname") ?? "";
//       _currentLastname = prefs.getString("lastname") ?? "";
//       _currentUserName = prefs.getString('displayName') ?? "";
//       _currentUserImg = prefs.getString("userImg") ?? "";
//     });
//   }
//
//   void _onFragmentChanged(int index) {
//     setState(() {
//       _selectedFragmentIndex = index;
//     });
//   }
//
//   Future<void> _handleMessage(User receiver) async {
//     var rooms =
//         await fetchSingleChatRoom(context, [receiver.id, _currentUserId]);
//     if (rooms.isNotEmpty) {
//       ChatRoom chatRoom = rooms[0];
//       var receiverAtIndex = 0;
//       var senderAtIndex = 1;
//       if (chatRoom.users[0].id == _currentUserId) {
//         receiverAtIndex = 1;
//         senderAtIndex = 0;
//       }
//       await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ChatActivity(
//             chatRoom: rooms[0],
//             receiverAtIndex: receiverAtIndex,
//             senderAtIndex: senderAtIndex,
//           ),
//         ),
//       );
//     } else {
//       await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ChatActivity(
//             chatRoom: ChatRoom(
//                 id: 'id',
//                 users: [
//                   receiver,
//                   User(
//                       id: _currentUserId,
//                       username: 'username',
//                       firstname: _currentFirstname,
//                       lastname: _currentLastname,
//                       displayName: _currentUserName,
//                       userImg: _currentUserImg,
//                       userNameId: 'userNameId',
//                       googleId: 'googleId',
//                       verified: false)
//                 ],
//                 lastChat: 'lastChat',
//                 lastChatTime: '',
//                 unreadCount: 0,
//                 blockedBy: []),
//             senderAtIndex: 1,
//             receiverAtIndex: 0,
//           ),
//         ),
//       );
//     }
//   }
//
//   Future<void> _refresh() async {
//     final profileNotifier = ref.read(profileProvider(widget.id).notifier);
//     if (profileNotifier.isLoading) {
//       //  already fetching or fetched, no need to refresh
//       return;
//     }
//     // not fetched, refresh
//     await profileNotifier.fetchProfile(widget.id);
//   }
//
//   Future<void> updateCurrentprofile(Map<String, dynamic> data) async {
//     await ref
//         .read(profileProvider(_currentUserId).notifier)
//         .updateProfileApi(context, data);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final profile = ref.watch(profileProvider(widget.id));
//     Profile? currentProfile;
//     if (_currentUserId != "") {
//       currentProfile = ref.watch(profileProvider(_currentUserId));
//     }
//
//     if (profile == null) {
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text("Profile Not Found"),
//           backgroundColor: const Color.fromARGB(255, 211, 232, 255),
//           titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
//           elevation: 0,
//         ),
//         body: const Center(
//           child: Text(
//             "The profile you are looking for does not exist.",
//             style: TextStyle(fontSize: 16, color: Colors.black54),
//           ),
//         ),
//       );
//     }
//
//     final List<Widget> fragments = [
//       ClubFragmentPage(
//         query: "?members=${widget.id}",
//         page: _buildInfoSection(profile),
//       ),
//       EventFragmentPage(
//         query: _currentUserId == widget.id
//             ? "?\$or[0][registerdTeamLead]=${widget.id}&\$or[1][admin]=${widget.id}"
//             : "?\$or[0][registerdTeamLead]=${widget.id}&\$or[1][admin]=${widget.id}&stepsDone=6",
//         page: _buildInfoSection(profile),
//       ),
//     ];
//
//     final List<Widget> appBarActions = [
//       IconButton(
//         icon: const Icon(Icons.more_horiz),
//         onPressed: () {
//           final BottomSheetProfileInfo sheetCollegeInfo =
//               BottomSheetProfileInfo();
//           sheetCollegeInfo.showBottomSheet(
//               context,
//               currentProfile!,
//               profile.id,
//               currentProfile.blockedUser!.contains(profile.id),
//               updateCurrentprofile);
//         },
//       ),
//       const SizedBox(
//         width: 8,
//       )
//     ];
//
//     return Scaffold(
//         backgroundColor:const Color(0xffF9FAFB),
//         appBar: AppBar(
//           title: Row(
//             children: [
//               Flexible(
//                 child: Text(
//                   profile.user.userName,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               if (profile.user.verified)
//                 const Icon(
//                   Icons.verified_outlined,
//                   size: 15,
//                   color: Colors.blue,
//                 ),
//             ],
//           ),
//           backgroundColor: const Color.fromARGB(255, 211, 232, 255),
//           titleTextStyle: const TextStyle(
//               color: Color.fromARGB(255, 27, 15, 15), fontSize: 18),
//           elevation: 0,
//           actions: appBarActions,
//         ),
//         body: fragments[_selectedFragmentIndex]);
//   }
//
//   Widget _buildInfoSection(Profile profile) {
//     Future<void> handleProfileForm() async {
//       await Navigator.push(
//         context,
//         MaterialPageRoute(
//             builder: (context) => EditProfileActivity(
//                   profile: profile,
//                 )),
//       );
//     }
//
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//           child: Stack(
//             children: [
//               Column(
//                 children: [
//                   const SizedBox(
//                     height: 45,
//                   ),
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     margin: const EdgeInsets.all(2),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Stack(
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             const SizedBox(height: 35),
//                             Row(
//                               children: [
//                                 Flexible(
//                                   child: Text(
//                                     profile.user.displayName,
//                                     style: const TextStyle(
//                                       fontSize: 22,
//                                       fontWeight: FontWeight.w600,
//                                       color: Colors.black87,
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 if (profile.user.verified)
//                                   const Icon(
//                                     Icons.verified_outlined,
//                                     size: 15,
//                                     color: Colors.blue,
//                                   ),
//                               ],
//                             ),
//                             const SizedBox(height: 8),
//                             if (profile.bio.isNotEmpty)
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: [
//                                   Icon(Icons.info_outline,
//                                       size: 18, color: Colors.grey[700]),
//                                   const SizedBox(width: 8),
//                                   Expanded(
//                                       child: Text(
//                                     profile.bio,
//                                     style: TextStyle(
//                                         color: Colors.grey[700],
//                                         overflow: TextOverflow.visible),
//                                   )),
//                                 ],
//                               ),
//                             const SizedBox(height: 4),
//                             if (profile.user.college != null)
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: [
//                                   Icon(Icons.school,
//                                       size: 18, color: Colors.grey[700]),
//                                   const SizedBox(width: 8),
//                                   Expanded(
//                                       child: Text(
//                                     profile.user.college!.collegeName,
//                                     style: TextStyle(
//                                         color: Colors.grey[700],
//                                         overflow: TextOverflow.visible),
//                                   )),
//                                 ],
//                               ),
//                             const SizedBox(height: 4),
//                             if (profile.currentLocation.isNotEmpty)
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: [
//                                   Icon(Icons.location_on_outlined,
//                                       size: 18, color: Colors.grey[700]),
//                                   const SizedBox(width: 8),
//                                   Text(
//                                     profile.currentLocation,
//                                     style: TextStyle(color: Colors.grey[700]),
//                                   ),
//                                 ],
//                               ),
//                             const SizedBox(height: 4),
//                             if (profile.email.isNotEmpty)
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: [
//                                   Icon(Icons.mail_outline,
//                                       size: 18, color: Colors.grey[700]),
//                                   const SizedBox(width: 8),
//                                   Expanded(
//                                       child: Text(
//                                     profile.email,
//                                     style: TextStyle(
//                                         color: Colors.grey[700],
//                                         overflow: TextOverflow.visible),
//                                   )),
//                                 ],
//                               ),
//                             const SizedBox(height: 4),
//                             if (profile.website.isNotEmpty)
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: [
//                                   Icon(Icons.link,
//                                       size: 18, color: Colors.grey[700]),
//                                   const SizedBox(width: 8),
//                                   Expanded(
//                                       child: Text(
//                                     profile.website,
//                                     style: TextStyle(
//                                         color: Colors.grey[700],
//                                         overflow: TextOverflow.visible),
//                                   )),
//                                 ],
//                               ),
//                             const SizedBox(height: 8),
//                             if (widget.id != _currentUserId)
//                               Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                     vertical: 8, horizontal: 16),
//                                 child: Row(
//                                   children: [
//                                     Expanded(
//                                       child: OutlinedButton.icon(
//                                         onPressed: () async {
//                                           PostUser receiver = profile.user;
//                                           await _handleMessage(User(
//                                               id: receiver.id,
//                                               username: receiver.userName,
//                                               firstname: receiver.firstname,
//                                               lastname: receiver.lastname,
//                                               displayName: receiver.displayName,
//                                               userImg: receiver.userImg,
//                                               userNameId: receiver.userName,
//                                               googleId: receiver.googleId,
//                                               verified: receiver.verified));
//                                         },
//                                         icon: const Icon(
//                                           Icons.mail,
//                                           color: Colors.blue,
//                                         ),
//                                         label: const Text('Message'),
//                                         style: OutlinedButton.styleFrom(
//                                           backgroundColor: Colors.white,
//                                           padding: const EdgeInsets.all(12),
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(8.0),
//                                           ),
//                                           foregroundColor: Colors.blue,
//                                           side: const BorderSide(
//                                               color: Colors
//                                                   .blue), // Set the border color here
//                                         ),
//                                       ),
//                                     ),
//                                     const SizedBox(
//                                         width: 8), // Space between buttons
//                                     Expanded(
//                                       child: OutlinedButton.icon(
//                                         onPressed: () {
//                                           Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                                 builder: (context) =>
//                                                     ReportActivity(
//                                                       id: profile.id,
//                                                       reportOn: "profile",
//                                                     )),
//                                           );
//                                         },
//                                         icon: const Icon(
//                                           Icons.report_outlined,
//                                           color: Colors.blue,
//                                         ),
//                                         label: const Text('Report'),
//                                         style: OutlinedButton.styleFrom(
//                                           backgroundColor: Colors.white,
//                                           padding: const EdgeInsets.all(12),
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(8.0),
//                                           ),
//                                           foregroundColor: Colors.blue,
//                                           side: const BorderSide(
//                                               color: Colors
//                                                   .blue), // Set the border color here
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                           ],
//                         ),
//                         if (_currentUserId == widget.id)
//                           Positioned(
//                             right: 0,
//                             top: 0,
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: Colors.blue,
//                                 shape: BoxShape.circle,
//                                 border:
//                                     Border.all(color: Colors.white, width: 2),
//                               ),
//                               child: IconButton(
//                                 icon: const Icon(Icons.edit,
//                                     color: Colors.white, size: 20),
//                                 onPressed: () {
//                                   handleProfileForm();
//                                 },
//                               ),
//                             ),
//                           )
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               Positioned(
//                   top: 0,
//                   left: (MediaQuery.of(context).size.width / 2) - 63,
//                   child: CircleAvatar(
//                     radius: 45,
//                     backgroundImage: NetworkImage(profile.user.userImg),
//                   )),
//             ],
//           ),
//         ),
//         Container(
//           color: Colors.white,
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               const SizedBox(width: 16),
//               _buildButton('Club', 0),
//               const SizedBox(width: 8),
//               _buildButton('Event', 1),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildButton(String text, int index) {
//     bool isActive = _selectedFragmentIndex == index;
//
//     return isActive
//         ? ElevatedButton(
//             onPressed: () {
//               _onFragmentChanged(index);
//             },
//             style: ButtonStyle(
//               textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 13)),
//               backgroundColor: WidgetStateProperty.all(
//                   Colors.blue), // Active button background color
//               foregroundColor: WidgetStateProperty.all(
//                   Colors.white), // Active button text color
//               shape: WidgetStateProperty.all(
//                 RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8.0),
//                 ),
//               ),
//             ),
//             child: Text(text),
//           )
//         : OutlinedButton(
//             onPressed: () {
//               _onFragmentChanged(index);
//             },
//             style: ButtonStyle(
//               textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 13)),
//               foregroundColor: WidgetStateProperty.all(
//                   Colors.black), // Inactive button text color
//               side: WidgetStateProperty.all(const BorderSide(
//                   color: Colors.transparent)), // Inactive button border color
//               shape: WidgetStateProperty.all(
//                 RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8.0),
//                 ),
//               ),
//             ),
//             child: Text(text),
//           );
//   }
//
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../api/provider/profile_provider.dart';
import 'calander_screen.dart';

class ProfileActivity extends ConsumerStatefulWidget {
  final String id;
  const ProfileActivity({super.key, required  this.id});

  @override
  ConsumerState<ProfileActivity> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileActivity> {

  @override
  Widget build(BuildContext context) {
    final profileData = ref.watch(profileProvider(widget.id));

    return Scaffold(
      backgroundColor:const Color(0xffF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        title: Text("Profile", style: GoogleFonts.poppins()),
        leading: InkWell(
            onTap:(){
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back)
        ),
        actions: const [
          Icon(Icons.search_rounded, color: Color(0xff3C393C)),
          SizedBox(width: 10),
          Icon(Icons.notifications, color: Color(0xff3C393C)),
          SizedBox(width: 10),
          Icon(Icons.more_vert_outlined, color: Color(0xff3C393C)),
        ],
      ),
      body: profileData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(
                    profileData.user.userImg ?? 'assets/images/profile.png',
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  profileData.user.displayName ?? "No Name",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  profileData.email ?? "Unknown Email",
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
            profileTile(Icons.school, "My Campus"),
            profileTile(Icons.access_time_filled_sharp, "Upcoming Reminder"),
            profileTile(Icons.groups_2_rounded, "Communities"),
            profileTile(Icons.support_agent_outlined, "Contact Support"),
            profileTile(Icons.settings_sharp, "Settings & Privacy"),
            profileTile(Icons.share_sharp, "Invite and Share"),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget profileIconButton(IconData icon, String label,VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap:onTap,
          child: CircleAvatar(
            backgroundColor: const Color(0xFFE9ECFB),
            child: Icon(icon, color: Colors.indigo,size:20,weight:200,),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
  
  Widget profileTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xff1A237E),size:21,),
      title: Text(title,style:const TextStyle(color:Color(0xff000000),fontWeight:FontWeight.w500),),
      trailing: const Icon(Icons.chevron_right,color:Color(0xff9CA3AF),),
      onTap: () {},
    );
  }

}

