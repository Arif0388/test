import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learningx_flutter_app/Screens/auth/sign_in.dart';
import 'package:learningx_flutter_app/Screens/college/college_selection_search.dart';
import 'package:learningx_flutter_app/api/common/launch_url.dart';
import 'package:learningx_flutter_app/api/provider/auth_provider.dart';
import 'package:learningx_flutter_app/api/provider/extra_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkRequiredUpdate();
  }

  void checkRequiredUpdate() async {
    AuthProvider authProvider = AuthProvider();
    bool isRequiredUpdate = false;

    try {
      isRequiredUpdate = await authProvider
          .checkRequiredUpdate(context)
          .timeout(const Duration(seconds: 1), onTimeout: () {
        return false; // Default to false on timeout
      });
    } catch (e) {
      // Handle any exceptions that might occur
      print('Error: $e');
      isRequiredUpdate = false;
    }
    if (!kIsWeb && isRequiredUpdate) {
      showDialog(
        context: context,
        barrierDismissible:
            false, // Prevent closing the dialog by tapping outside
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Update Required'),
            content: const Text(
              'A new version of the app is available. Please update to continue.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Code to open the app store or play store
                  openAppStore();
                },
                child: const Text('Update'),
              ),
            ],
          );
        },
      );
    } else {
      // Simulate a delay before transitioning to the next screen
      Timer(const Duration(milliseconds: 100), () {
        // Navigate to the next screen
        checkLoginStatus();
      });
    }
  }

  void openAppStore() {
    context.push("/apps");
  }

  void checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String collegeId = prefs.getString('college') ?? "";
    if (isLoggedIn && collegeId != "") {
      logUserActivity();
      context.go("/home");
    } else if (isLoggedIn && collegeId == "") {
      Map<String, dynamic> map = HashMap();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CollegeSelectionWidget(map: map),
        ),
      );
    } else {
      if (kIsWeb) {
        LaunchUrl.openUrl("https://www.clubchat.live/about");
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SignIn()),
        );
      }
    }
  }

  void logUserActivity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var collegeId = prefs.getString('college') ?? "";
    await logUserActivityApi(context, {
      'activityType': "active",
      'college': collegeId == "" ? null : collegeId,
      'platform': kIsWeb ? "mWeb" : Platform.operatingSystem
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xff3368C6),
      body: ColoredBox(
          color: const Color.fromARGB(255, 255, 254, 253),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset("assets/images/learningx_icon.png"),
              ],
            ),
          )),
    );
  }
}
