import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:learningx_flutter_app/api/provider/auth_provider.dart';

class VerificationActivity extends StatelessWidget {
  final TextEditingController otpController = TextEditingController();
  final String user;

  VerificationActivity({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    void handleNextBtn() async {
      if (otpController.text.isNotEmpty) {
        Map<String, String> data = HashMap();
        data['token'] = otpController.text;
        data['user'] = user;
        AuthProvider authProvider = AuthProvider();
        authProvider.validateOTPRequest(context, data);
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
        title: const Text('Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Your Account have been created!!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.blue, // Use active color
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'We have sent an OTP.\nIt may take 1-2 minutes.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Enter OTP',
              style: TextStyle(
                fontSize: 20,
                color: Colors.blue, // Use active color
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'OTP',
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                handleNextBtn();
              },
              child: const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}
