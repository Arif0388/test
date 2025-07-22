import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../api/provider/profile_provider.dart';
import 'calander_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String id;
  const ProfileScreen({super.key, required  this.id});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {

  @override
  Widget build(BuildContext context) {
    final profileData = ref.watch(profileProvider(widget.id));

    return Scaffold(
      backgroundColor:const Color(0xffF9FAFB),
      appBar: AppBar(
        title: Text("Profile", style: GoogleFonts.poppins()),
        leading: InkWell(
            onTap:(){
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back)),
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

