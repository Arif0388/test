import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/college/college_selection_search.dart';
import 'package:learningx_flutter_app/api/provider/auth_provider.dart';

class SignUpForm2Screen extends ConsumerStatefulWidget {
  final Map<String, dynamic> data;
  const SignUpForm2Screen({super.key, required this.data});

  @override
  ConsumerState<SignUpForm2Screen> createState() => _SignUp2FormActivityState();
}

class _SignUp2FormActivityState extends ConsumerState<SignUpForm2Screen> {
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController collegeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController rePasswordController = TextEditingController();
  String errorMessage = '';
  String emailDomain = "";

  @override
  void initState() {
    if (widget.data.containsKey('college')) {
      firstnameController.text = widget.data['firstname'];
      lastnameController.text = widget.data['lastname'];
      emailController.text = widget.data['username'];
      collegeController.text = widget.data['collegeName'];
      emailDomain = widget.data['emailDomain'];
    }
    super.initState();
  }

  @override
  void dispose() {
    firstnameController.dispose();
    lastnameController.dispose();
    collegeController.dispose();
    emailController.dispose();
    passwordController.dispose();
    rePasswordController.dispose();
    super.dispose();
  }

  void handleSignupBtn() async {
    setState(() {
      if (firstnameController.text.isEmpty ||
          lastnameController.text.isEmpty ||
          emailController.text.isEmpty) {
        errorMessage = '* required';
      } else if (passwordController.text.length < 6) {
        errorMessage = 'Password must be at least 6 characters long';
      } else if (passwordController.text != rePasswordController.text) {
        errorMessage = 'Passwords do not match';
      } else {
        errorMessage = '';
      }
    });
    if (errorMessage.isEmpty) {
      Map<String, dynamic> map = widget.data;
      if (widget.data.containsKey('college') &&
          emailController.text.contains(widget.data['emailDomain'])) {
        map['firstname'] = firstnameController.text;
        map['lastname'] = lastnameController.text;
        map['gender'] = "male";
        map['email'] = emailController.text;
        map['username'] = emailController.text;
        map['password'] = passwordController.text;
        AuthProvider authProvider = AuthProvider();
        authProvider.signUpUser(context, map);
      } else if (widget.data.containsKey('emailDomain')) {
        setState(() {
          errorMessage =
              "Email must contain ${widget.data['emailDomain']} domain";
        });
      } else {
        errorMessage = "Select a campus";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/icon_image.png',
                      width: 50,
                      height: 50,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Club',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const Text(
                      '-',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color:  Color.fromARGB(255, 59, 128, 228)),
                    ),
                    const Text(
                      'Chat',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'First Name*',
                            style: TextStyle(
                                fontSize: 12, color: Colors.teal[700]),
                          ),
                          TextField(
                            controller: firstnameController,
                            decoration: InputDecoration(
                              hintText: 'First Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            maxLength: 25,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Last Name*',
                            style: TextStyle(
                                fontSize: 12, color: Colors.teal[700]),
                          ),
                          TextField(
                            controller: lastnameController,
                            decoration: InputDecoration(
                              hintText: 'Last Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            maxLength: 25,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(
                  'Email* ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.teal[700],
                  ),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  maxLength: 50,
                ),
                Text(
                  'Select Campus* ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.teal[700],
                  ),
                ),
                Center(
                  child: InkWell(
                    onTap: () {
                      (widget.data)['firstname'] = firstnameController.text;
                      (widget.data)['lastname'] = lastnameController.text;
                      (widget.data)['username'] = emailController.text;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CollegeSelectionWidget(
                                  map: widget.data,
                                )),
                      );
                    },
                    child: IgnorePointer(
                      child: TextFormField(
                        controller: collegeController,
                        decoration: InputDecoration(
                          hintText: 'Select Campus',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                        enabled: false,
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (emailDomain.isNotEmpty)
                  Text(
                    '* Email must be $emailDomain domain email.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  'Set Password',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Password* ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.teal[700],
                  ),
                ),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    hintText: 'Password (Min. 6 letters)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  obscureText: true,
                  maxLength: 20,
                ),
                Text(
                  'Confirm Password*',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.teal[700],
                  ),
                ),
                TextField(
                  controller: rePasswordController,
                  decoration: InputDecoration(
                    hintText: 'Re-type Password (Min. 6 letters)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  obscureText: true,
                  maxLength: 20,
                ),
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      handleSignupBtn();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 0),
                    ),
                    child: const Text('Next'),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text('Already have an account? '),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Sign In',
                        style: TextStyle(color: Colors.blue, fontSize: 16),
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
