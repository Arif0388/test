import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:learningx_flutter_app/Screens/explore/explore_page.dart';
import 'package:learningx_flutter_app/Screens/extra/contact_us.dart';
import 'package:learningx_flutter_app/Screens/extra/setting_privacy.dart';
import 'package:learningx_flutter_app/api/common/launch_url.dart';
import 'package:learningx_flutter_app/api/provider/extra_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuFeed extends ConsumerStatefulWidget {
  const MenuFeed({super.key});

  @override
  ConsumerState<MenuFeed> createState() => _MenuFeedState();
}

class _MenuFeedState extends ConsumerState<MenuFeed> {
  var _currentUserId = "";
  var _currentUserName = "user_name";
  var _currentUserImg =
      "https://learningx-s3.s3.ap-south-1.amazonaws.com/user.png";
  var _collegeId = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentUser();
    });
  }

  _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('id') ?? "";
      _currentUserName = prefs.getString('displayName') ?? "User";
      _currentUserImg = prefs.getString("userImg") ?? "";
      _collegeId = prefs.getString('college') ?? "";
    });
  }

  Future<void> shareText() async {
    const String text =
        "Hey there, you can use the link below to download the app and join the campus clubs in a hassle-free way! \nSee you in Campus Clubs.\n\n https://www.clubchat.live/apps";
    
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

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Get Azure ID before clearing preferences
    String azureId = prefs.getString('azureId') ?? "";

    await logUserActivityApi(context, {
      'activityType': "logout",
      'college': _collegeId.isEmpty ? null : _collegeId,
      'platform': kIsWeb ? "mWeb" : Platform.operatingSystem
    });

    await prefs.clear();

    final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
    await googleSignIn.signOut();

    if (azureId.isNotEmpty) {
      final Uri logoutUrl = Uri.parse(
          'https://login.microsoftonline.com/common/oauth2/v2.0/logout');
      await LaunchUrl.openUrl(logoutUrl.toString());
    }

    Navigator.of(context).popUntil((route) => route.isFirst);
    context.go("/");
  }

  @override
  Widget build(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: const Text("Are you sure?"),
      content: const Text("Do you want to logout?"),
      actions: [
        TextButton(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text("Logout"),
          onPressed: () => logout(context),
        )
      ],
    );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          padding: const EdgeInsets.only(left: 8),
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (Navigator.canPop(context)) Navigator.pop(context);
                        context.push("/profile/$_currentUserId");
                      },
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: _currentUserImg.isNotEmpty
                            ? NetworkImage(_currentUserImg)
                            : const AssetImage("assets/images/default_avatar.png") as ImageProvider,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_currentUserName),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Upcoming Reminder'),
              onTap: () {
                if (Navigator.canPop(context)) Navigator.pop(context);
                context.push("/reminder");
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_phone),
              title: const Text('Contact Us'),
              onTap: () {
                if (Navigator.canPop(context)) Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactUs()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.groups_outlined),
              title: const Text('Communities'),
              onTap: () {
                if (Navigator.canPop(context)) Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ExplorePage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Setting & Privacy'),
              onTap: () {
                if (Navigator.canPop(context)) Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SettingAndPrivacy(id: _currentUserId)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Invite and Share'),
              onTap: () async {
                await shareText();
                if (Navigator.canPop(context)) Navigator.pop(context);
              },
            ),
            if (kIsWeb)
              ListTile(
                leading: const Icon(Icons.install_mobile_outlined),
                title: const Text('Download App'),
                onTap: () {
                  if (Navigator.canPop(context)) Navigator.pop(context);
                  context.go("/apps");
                },
              ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                if (Navigator.canPop(context)) Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return alert;
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
