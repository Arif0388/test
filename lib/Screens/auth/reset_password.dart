// import 'dart:collection';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:learningx_flutter_app/api/provider/auth_provider.dart';
//
// class ResetPasswordScreen extends ConsumerStatefulWidget {
//   final String user;
//   const ResetPasswordScreen({super.key, required this.user});
//
//   @override
//   ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordState();
// }
//
// class _ResetPasswordState extends ConsumerState<ResetPasswordScreen> {
//   final TextEditingController otpController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController rePasswordController = TextEditingController();
//   String errorMessage = '';
//
//   @override
//   Widget build(BuildContext context) {
//     void handleNextBtn() async {
//       setState(() {
//         if (otpController.text.isEmpty) {
//           errorMessage = 'Enter OTP';
//         } else if (passwordController.text.length < 6) {
//           errorMessage = 'Password must be at least 6 characters long';
//         } else if (passwordController.text != rePasswordController.text) {
//           errorMessage = 'Passwords do not match';
//         } else {
//           errorMessage = '';
//         }
//       });
//       if (errorMessage.isEmpty) {
//         Map<String, String> data = HashMap();
//         data['token'] = otpController.text;
//         data['user'] = widget.user;
//         data['password'] = passwordController.text;
//         AuthProvider authProvider = AuthProvider();
//         authProvider.resetPassword(context, data);
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
//       body: Center(
//         child: Container(
//           margin: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text(
//                 'We have sent an OTP!!',
//                 style: TextStyle(
//                   fontSize: 18,
//                   color: Colors.blue,
//                 ),
//               ),
//               const SizedBox(height: 2),
//               const Text(
//                 '*It may take 1-2 minutes.',
//                 style: TextStyle(
//                   fontSize: 15,
//                   color: Colors.black,
//                 ),
//               ),
//               const SizedBox(height: 40),
//               TextFormField(
//                 controller: otpController,
//                 decoration: const InputDecoration(
//                   labelText: 'Enter OTP',
//                   labelStyle: TextStyle(color: Colors.blue),
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//               const SizedBox(height: 20),
//               TextFormField(
//                 controller: passwordController,
//                 obscureText: true,
//                 decoration: const InputDecoration(
//                   labelText: 'Password',
//                   labelStyle: TextStyle(color: Colors.blue),
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               TextFormField(
//                 controller: rePasswordController,
//                 obscureText: true,
//                 decoration: const InputDecoration(
//                   labelText: 'Re-type Password',
//                   labelStyle: TextStyle(color: Colors.blue),
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               if (errorMessage.isNotEmpty)
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     errorMessage,
//                     style: const TextStyle(color: Colors.red),
//                   ),
//                 ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   handleNextBtn();
//                 },
//                 style: ElevatedButton.styleFrom(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: const Text('Verify'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/api/provider/auth_provider.dart';
class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String user;
  const ResetPasswordScreen({super.key, required this.user});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends ConsumerState<ResetPasswordScreen> {
  final TextEditingController otpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController rePasswordController = TextEditingController();

  bool showPassword = false;
  bool showRePassword = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    void handleNextBtn() async {
      setState(() {
        if (otpController.text.isEmpty) {
          errorMessage = 'Enter OTP';
        } else if (passwordController.text.length < 6) {
          errorMessage = 'Password must be at least 6 characters long';
        } else if (passwordController.text != rePasswordController.text) {
          errorMessage = 'Passwords do not match';
        } else {
          errorMessage = '';
        }
      });

      if (errorMessage.isEmpty) {
        Map<String, String> data = HashMap();
        data['token'] = otpController.text;
        data['user'] = widget.user;
        data['password'] = passwordController.text;

        AuthProvider authProvider = AuthProvider();
        authProvider.resetPassword(context, data);
      }
    }

    return Scaffold(
      backgroundColor:const Color(0xffF9FAFB),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                const Icon(Icons.lock_outline, size: 60, color: Colors.black54),
                const SizedBox(height: 20),
                const Text(
                  "Set new password",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Must be atleast 8 characters",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 32),

                // OTP Field
                TextFormField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.shield_outlined),
                    labelText: 'Enter OTP',
                    labelStyle: const TextStyle(color: Colors.black87),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),

                // New Password Field
                TextFormField(
                  controller: passwordController,
                  obscureText: !showPassword,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock),
                    labelText: 'New password',
                    labelStyle: const TextStyle(color: Colors.black87),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          showPassword = !showPassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Confirm Password Field
                TextFormField(
                  controller: rePasswordController,
                  obscureText: !showRePassword,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline),
                    labelText: 'Confirm password',
                    labelStyle: const TextStyle(color: Colors.black87),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showRePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          showRePassword = !showRePassword;
                        });
                      },
                    ),
                  ),
                ),

                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            errorMessage,
                            style: const TextStyle(color: Colors.orange, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 30),

                // Reset Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: handleNextBtn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Reset password',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    '← Back to log in',
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                ),

                const SizedBox(height: 32),

                // Bottom Progress Indicator (Step 2 of 2)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

