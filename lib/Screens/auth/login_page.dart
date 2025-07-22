// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:learningx_flutter_app/Screens/auth/forgot_password.dart';
import 'package:learningx_flutter_app/api/provider/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    AuthProvider authProvider = AuthProvider();
    Map<String, String> data = HashMap();
    data['username'] = _usernameController.text;
    data['password'] = _passwordController.text;
    if (kIsWeb) {
      data['platform'] = "mWeb";
    } else {
      data['platform'] = Platform.operatingSystem;
    }
    await authProvider.loginUser(context, data);
  }

  @override
  Widget build(BuildContext context) {
    Future<dynamic> handleForgotPassswordBtn() {
      return Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ForgottenPasswordActivity()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6FBFF), // light gradient background
      body: Container(
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/icon_image.png',
                        width: 60,
                        height: 60,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Club',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const Text(
                        '-',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 59, 128, 228)),
                      ),
                      const Text(
                        'Chat',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32.0),
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: 'email',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    obscureText: true,
                    controller: _passwordController,
                    decoration: InputDecoration(
                      hintText: 'password',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.all(8),
                    child: GestureDetector(
                        onTap: () {
                          handleForgotPassswordBtn();
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.teal[700],
                          ),
                        )),
                  ),
                  const SizedBox(height: 8.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _handleLogin,
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black),
                      children: [
                        const TextSpan(text: "Don't have an Account? "),
                        TextSpan(
                          text: 'Sign up',
                          style: const TextStyle(color: Colors.blue),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pop(context);
                            },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
