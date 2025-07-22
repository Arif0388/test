import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learningx_flutter_app/api/common/launch_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingAndPrivacy extends StatefulWidget {
  final String id;
  const SettingAndPrivacy({super.key, required this.id});

  @override
  State<SettingAndPrivacy> createState() => _SettingAndPrivacyState();
}

class _SettingAndPrivacyState extends State<SettingAndPrivacy> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Setting & Privacy'),
          backgroundColor: const Color.fromARGB(255, 211, 232, 255),
          titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text("About Us"),
              onTap: () {
                LaunchUrl.openUrl("https://www.clubchat.live/about");
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text("Privacy Policy"),
              onTap: () {
                LaunchUrl.openUrl("https://www.clubchat.live/privacy-policy");
              },
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text("Terms And Conditions"),
              onTap: () {
                LaunchUrl.openUrl("https://www.clubchat.live/terms-conditions");
              },
            ),
            ListTile(
              leading: const Icon(Icons.supervised_user_circle),
              title: const Text("End User License Agreement"),
              onTap: () {
                LaunchUrl.openUrl("https://www.clubchat.live/eula");
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle_outlined),
              title: const Text("Close Account"),
              onTap: () async {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.of(context).popUntil((route) => route.isFirst);
                context.go("/");
                LaunchUrl.openUrl(
                    "https://www.clubchat.live/user/close-account/${widget.id}");
              },
            )
          ],
        ));
  }
}
