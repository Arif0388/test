// import 'dart:collection';
//
// import 'package:flutter/material.dart';
// import 'package:learningx_flutter_app/api/provider/auth_provider.dart';
//
// class ForgottenPasswordActivity extends StatelessWidget {
//   final TextEditingController usernameController = TextEditingController();
//   ForgottenPasswordActivity({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     void handleNextBtn() async {
//       if (usernameController.text.isNotEmpty) {
//         Map<String, String> data = HashMap();
//         data['username'] = usernameController.text;
//         AuthProvider authProvider = AuthProvider();
//         authProvider.resetPasswordRequest(context, data);
//       }
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Reset Password'),
//         backgroundColor: const Color.fromARGB(255, 211, 232, 255),
//         titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             const SizedBox(height: 64),
//             const Text(
//               'Enter your username',
//               style: TextStyle(
//                 fontSize: 20,
//                 color: Colors.blue,
//               ),
//             ),
//             const SizedBox(height: 10),
//             TextFormField(
//               controller: usernameController,
//               decoration: InputDecoration(
//                 labelText: 'Email id',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 handleNextBtn();
//               },
//               style: ElevatedButton.styleFrom(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 minimumSize: const Size(double.infinity, 0),
//               ),
//               child: const Text('Reset Password'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:learningx_flutter_app/api/provider/auth_provider.dart';

class ForgottenPasswordActivity extends StatefulWidget {
  const ForgottenPasswordActivity({super.key});

  @override
  State<ForgottenPasswordActivity> createState() =>
      _ForgottenPasswordActivityState();
}

class _ForgottenPasswordActivityState extends State<ForgottenPasswordActivity> {
  final TextEditingController usernameController = TextEditingController();
  String errorMessage = '';
  bool isLoading = false;

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    return emailRegex.hasMatch(email);
  }

  void handleNextBtn() {
    final email = usernameController.text.trim();

    if (email.isEmpty) {
      setState(() {
        errorMessage = "Please enter your email.";
      });
      return;
    }

    if (!isValidEmail(email)) {
      setState(() {
        errorMessage = "Enter a valid email address.";
      });
      return;
    }

    setState(() {
      errorMessage = '';
      isLoading = true;
    });

    Map<String, String> data = HashMap();
    data['username'] = email;

    AuthProvider authProvider = AuthProvider();
    authProvider.resetPasswordRequest(context, data);

    // UI feedback — wait a bit then reset loading (not ideal but avoids void await issue)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => isLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color(0xffF9FAFB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),

                const SizedBox(height: 32),
                const Icon(Icons.fingerprint, size: 48, color: Colors.black54),
                const SizedBox(height: 16),
                const Text(
                  "Forgot Password?",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "No worries, we'll send you reset instructions.",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 32),

                Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    "Email Address",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.mail_outline),
                    hintText: "Enter your email",
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),

                if (errorMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4DB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            errorMessage,
                            style: const TextStyle(fontSize: 13, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: isLoading ? null : handleNextBtn,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: isLoading ? Colors.grey : const Color(0xFF1A73E8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : const Text("Reset password", style: TextStyle(fontSize: 16)),
                ),

                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("← Back to log in",
                      style: TextStyle(color: Colors.black87)),
                ),
                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
