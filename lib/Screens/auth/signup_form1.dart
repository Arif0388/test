import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:learningx_flutter_app/Screens/auth/signup_form2.dart';

class SignUpForm1Screen extends StatefulWidget {
  const SignUpForm1Screen({super.key});

  @override
  State<SignUpForm1Screen> createState() => _SignUp1ActivityState();
}

class _SignUp1ActivityState extends State<SignUpForm1Screen> {
  String birthday = '01/01/1970';
  String gender = 'male';
  final List<String> genderOptions = ['male', 'female', 'other'];
  String errorMessage = '';

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  void _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        birthday = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<Object?>? handNextBtn() {
      setState(() {
        if (firstNameController.text.isEmpty) {
          errorMessage = 'firstname is required!';
        } else {
          errorMessage = '';
        }
      });
      if (errorMessage.isEmpty) {
        Map<String, dynamic> map = HashMap();
        map['firstname'] = firstNameController.text;
        map['lastname'] = lastNameController.text;
        map['birthday'] = birthday;
        map['gender'] = gender;
        return Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignUpForm2Screen(data: map)),
        );
      } else {
        return null;
      }
    }

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/images/icon_image.png',
                      width: 50,
                      height: 50,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Learning',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const Text(
                      'X',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue, // Use active color
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                Text(
                  'First Name*',
                  style: TextStyle(fontSize: 12, color: Colors.teal[700]),
                ),
                TextField(
                  controller: firstNameController,
                  decoration: InputDecoration(
                    hintText: 'First Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLength: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  'Last Name*',
                  style: TextStyle(fontSize: 12, color: Colors.teal[700]),
                ),
                TextField(
                  controller: lastNameController,
                  decoration: InputDecoration(
                    hintText: 'Last Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLength: 40,
                ),
                Row(
                  children: [
                    Text(
                      'Birthday :-',
                      style: TextStyle(fontSize: 12, color: Colors.teal[700]),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      birthday,
                      style: const TextStyle(fontSize: 15, color: Colors.black),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Gender :-',
                      style: TextStyle(fontSize: 12, color: Colors.teal[700]),
                    ),
                    const SizedBox(width: 8),
                    DropdownMenu<String>(
                      initialSelection: gender,
                      label: const Text('Gender'),
                      onSelected: (String? newValue) {
                        setState(() {
                          gender = newValue!;
                        });
                      },
                      dropdownMenuEntries: genderOptions
                          .map<DropdownMenuEntry<String>>((String value) {
                        return DropdownMenuEntry<String>(
                          value: value,
                          label: value,
                        );
                      }).toList(),
                    ),
                  ],
                ),
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      handNextBtn();
                    },
                    style: ElevatedButton.styleFrom(
                      // primary: Colors.blue,
                      // onPrimary: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize:
                          const Size(double.infinity, 0), // Full-width button
                    ),
                    child: const Text(
                      'Next',
                    ),
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
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16), // Use active color
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
