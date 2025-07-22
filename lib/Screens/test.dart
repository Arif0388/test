import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:learningx_flutter_app/api/common/launch_url.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Future<void> _handleGoogleSignIn() async {
    try {} catch (error) {
      print(error);
    }
  }

  Future<void> _handleLogin() async {}

  Future<void> _handleAzureSign() async {}

  @override
  Widget build(BuildContext context) {
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
                // Logo
                Image.asset(
                  'assets/images/icon_image.png',
                  height: 150,
                ),
                const Spacer(flex: 2),
                const SizedBox(height: 16.0),
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
                  onPressed: _handleLogin,
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
                          recognizer: TapGestureRecognizer()..onTap = () {},
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
