// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:learningx_flutter_app/Screens/auth/activate_account.dart';
import 'package:learningx_flutter_app/Screens/auth/login_page.dart';
import 'package:learningx_flutter_app/Screens/auth/signup_form2.dart';
import 'package:learningx_flutter_app/api/common/launch_url.dart';
import 'package:learningx_flutter_app/api/provider/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignIn> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late AppLinks appLinks;

  final authorizationEndpoint = Uri.parse(
      'https://login.microsoftonline.com/common/oauth2/v2.0/authorize');
  final tokenEndpoint =
      Uri.parse('https://login.microsoftonline.com/common/oauth2/v2.0/token');
  final identifier = dotenv.env['AZURE_CLIENT_ID'] ?? "";
  final secret = dotenv.env['AZURE_CLIENT_SECRET'];
  var redirectUrl = Uri.parse(dotenv.env['AZURE_ANDROID_REDIRECT'] ?? "");

  oauth2.Client? client;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Optional clientId
    // clientId: dotenv.env['ANDROID_GOOGLE_CLIENT_ID'],
    scopes: [
      'email',
      'profile',
      'openid',
    ],
  );

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    if (kIsWeb) {
      redirectUrl = Uri.parse(dotenv.env['AZURE_WEB_REDIRECT'] ?? "");
    } else {
      if (Platform.isIOS || Platform.isMacOS) {
        redirectUrl = Uri.parse(dotenv.env['AZURE_IOS_REDIRECT'] ?? "");
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String token = prefs.getString('token') ?? "";
    String userId = prefs.getString('id') ?? "";
    AuthProvider authProvider = AuthProvider();
    if (isLoggedIn) {
      bool isTokenValid = await authProvider.checkTokenValidity(context);
      if (isTokenValid) {
        context.go("/home");
      } else {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        final GoogleSignIn googleSignIn = GoogleSignIn();
        await googleSignIn.signOut();

        String azureId = prefs.getString('azureId') ?? "";
        if (azureId != "") {
          final Uri logoutUrl = Uri.parse(
              'https://login.microsoftonline.com/common/oauth2/v2.0/logout');
          await LaunchUrl.openUrl(logoutUrl.toString());
        }
      }
    }
    if (token != "" && !isLoggedIn) {
      Navigator.of(context).pop();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ActivateAccount(id: userId)),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      print(googleUser);

      if (googleUser != null) {
        GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        String? accessToken = googleAuth.accessToken;
        String? idToken = googleAuth.idToken;

        if (kIsWeb) {
          if (accessToken != null) {
            Map<String, String> map = HashMap();
            map['token'] = accessToken;
            map['url'] = "login";
            map['platform'] = "mWeb";
            AuthProvider authProvider = AuthProvider();
            await authProvider.googleUserSignIn(context, map);
          } else {
            // Handle the case where idToken is null
            print('Google Sign-In failed: idToken is null');
          }
        } else {
          if (idToken != null) {
            Map<String, String> map = HashMap();
            map['token'] = idToken;
            map['url'] = "react/login";
            map['platform'] = Platform.operatingSystem;
            AuthProvider authProvider = AuthProvider();
            await authProvider.googleUserSignIn(context, map);
          } else {
            // Handle the case where idToken is null
            print('Google Sign-In failed: idToken is null');
          }
        }
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleAzureSign() async {
    var grant = oauth2.AuthorizationCodeGrant(
      identifier,
      authorizationEndpoint,
      tokenEndpoint,
    );

// Generate the authorization URL
    var authorizationUrl = grant.getAuthorizationUrl(
      redirectUrl,
      scopes: ["openid", "profile", "User.Read", "email", "offline_access"],
    );

    // Launch the URL
    await LaunchUrl.openUrl(authorizationUrl.toString());

    appLinks = AppLinks();
    appLinks.uriLinkStream.listen((Uri uri) async {
      if (uri.queryParameters.containsKey('code')) {
        closeInAppWebView();
        // Ensure that the authorization URL has been generated before this
        var client =
            await grant.handleAuthorizationResponse(uri.queryParameters);
        // Use the client to make authenticated requests
        final idToken = client.credentials.idToken;

        // You can now use the idToken as needed
        print('ID Token: $idToken');
        Map<String, String> map = HashMap();
        map['idToken'] = idToken!;
        if (kIsWeb) {
          map['platform'] = "mWeb";
        } else {
          map['platform'] = Platform.operatingSystem;
        }
        AuthProvider authProvider = AuthProvider();
        await authProvider.azureUserSignIn(context, map);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Future<dynamic> handSignupBtn() {
      Map<String, dynamic> map = HashMap();
      map['signup'] = true;
      return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SignUpForm2Screen(
                  data: map,
                )),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6FBFF), // light gradient background
      body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xFF90CAF9), // mid blue
                Color(0xFFE3F2FD), // very light blue
                Color(0xFFBBDEFB), // light-medium blue
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: SafeArea(
              child: Center(
            child: Column(
              children: [
                const Spacer(flex: 4),
                const Text(
                  'Join or Discover College Clubs and Events',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                // Logo
                Image.asset(
                  'assets/images/icon_image.png',
                  height: 150,
                ),
                const Spacer(flex: 2),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _handleGoogleSignIn,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/google.png', // Path to your asset image
                        height: 24,
                        width: 24,
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      const Text(
                        'Continue with Google',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                if (!kIsWeb)
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _handleAzureSign,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/microsoft.png', // Path to your asset image
                          height: 24,
                          width: 24,
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        const Text(
                          'Continue with Microsoft',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          10), // Set the border radius to 10
                    ),
                  ),
                  onPressed: handSignupBtn,
                  child: const Text(
                    'Sign up',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: const TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: 'Log in',
                          style: const TextStyle(
                            color: Color(0xFF008CFF),
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(fontSize: 11, color: Colors.black),
                    children: [
                      const TextSpan(
                          text:
                              "By signing In or Creating an account, you agree to Club-Chat's "),
                      TextSpan(
                        text: 'End User License Agreement',
                        style: const TextStyle(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            LaunchUrl.openUrl("https://www.clubchat.live/eula");
                          },
                      ),
                      const TextSpan(text: " and "),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: const TextStyle(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            LaunchUrl.openUrl(
                                "https://www.clubchat.live/privacy-policy");
                          },
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
              ],
            ),
          ))),
    );
  }
}
