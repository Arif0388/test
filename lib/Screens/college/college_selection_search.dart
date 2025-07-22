import 'dart:collection';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learningx_flutter_app/Screens/auth/signup_form2.dart';
import 'package:learningx_flutter_app/Screens/college/college_form.dart';
import 'package:learningx_flutter_app/api/model/college_model.dart';
import 'package:learningx_flutter_app/api/provider/college_provider.dart';
import 'package:learningx_flutter_app/api/provider/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CollegeSelectionWidget extends ConsumerStatefulWidget {
  final Map<String, dynamic> map;
  const CollegeSelectionWidget({super.key, required this.map});
  @override
  ConsumerState<CollegeSelectionWidget> createState() =>
      _CollegeSelectionState();
}

class _CollegeSelectionState extends ConsumerState<CollegeSelectionWidget> {
  List<College> _filteredItems = [];
  List<College> _allItems = [];
  var _currentUserId = "";
  var _currentFirstname = "user";
  var _currentLastname = "_name";
  var _currentCollegeId = "";
  var username = "";

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final collegeAsyncValue = ref.read(collegeProvider(""));
      collegeAsyncValue.whenData((data) {
        setState(() {
          _allItems = data;
          _filteredItems = data;
        });
      });
    });
  }

  _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString("id") ?? "";
      _currentFirstname = prefs.getString("firstname") ?? "";
      _currentLastname = prefs.getString("lastname") ?? "";
      _currentCollegeId = prefs.getString("college") ?? "";
      username = prefs.getString("username") ?? "";
    });
  }

  Future<void> subscribeToFCM(String collegeId) async {
    var firebaseMessaging = FirebaseMessaging.instance;
    if (Platform.isMacOS || Platform.isIOS) {
      String? apnsToken = await firebaseMessaging.getAPNSToken();
      if (apnsToken != null) {
        await firebaseMessaging.subscribeToTopic(collegeId);
      } else {
        await Future<void>.delayed(
          const Duration(seconds: 3),
        );
        apnsToken = await firebaseMessaging.getAPNSToken();
        if (apnsToken != null) {
          await firebaseMessaging.subscribeToTopic(collegeId);
        }
      }
    } else {
      await firebaseMessaging.subscribeToTopic(collegeId);
    }
  }

  Future<void> unsubscribeToFCM(String collegeId) async {
    var firebaseMessaging = FirebaseMessaging.instance;
    if (Platform.isMacOS || Platform.isIOS) {
      String? apnsToken = await firebaseMessaging.getAPNSToken();
      if (apnsToken != null) {
        await firebaseMessaging.unsubscribeFromTopic(collegeId);
      } else {
        await Future<void>.delayed(
          const Duration(seconds: 3),
        );
        apnsToken = await firebaseMessaging.getAPNSToken();
        if (apnsToken != null) {
          await firebaseMessaging.unsubscribeFromTopic(collegeId);
        }
      }
    } else {
      await firebaseMessaging.unsubscribeFromTopic(collegeId);
    }
  }

  void _filterItems(String query) {
    setState(() {
      _filteredItems = _allItems
          .where((item) =>
              item.collegeName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void handleTap(College college) async {
    if (widget.map.containsKey('signup')) {
      (widget.map)['college'] = college.id;
      (widget.map)['emailDomain'] = college.emailDomain;
      (widget.map)['collegeName'] = college.collegeName;
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SignUpForm2Screen(
                  data: widget.map,
                )),
      );
    } else {
      if (college.restricted && !username.contains(college.emailDomain)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("You must login with ${college.emailDomain} id!")),
        );
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('college', college.id);
        Map<String, dynamic> data = HashMap();
        data["_id"] = _currentUserId;
        data["firstname"] = _currentFirstname;
        data["lastname"] = _currentLastname;
        data['college'] = college.id;
        await updateUserApi(context, data);
        Navigator.pop(context);
        // context.push("/college/${college.id}");
        context.go("/home");
        await unsubscribeToFCM(_currentCollegeId);
        await subscribeToFCM(college.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Campus"),
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "Select Campus(*if not found?",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                const SizedBox(
                  width: 5,
                ),
                GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CollegeFormActivity(
                                    signupData: widget.map,
                                  )));
                    },
                    child: const Text(
                      "Click here ",
                      style: TextStyle(color: Colors.blue),
                    )),
                const Text(
                  ")",
                  style: TextStyle(color: Colors.black),
                )
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                contentPadding: const EdgeInsets.all(8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                _filterItems(value);
              },
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ref.watch(collegeProvider("")).when(
                    data: (data) {
                      if (_allItems.isEmpty) {
                        _allItems = data;
                        _filteredItems = data;
                      }
                      return ListView.builder(
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          College college = _filteredItems[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.all(8),
                            style: ListTileStyle.list,
                            // leading: Image.network(college.collegeImg),
                            title: Text(college.collegeName,
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              college.city.address,
                              maxLines: 1,
                            ),
                            onTap: () => {handleTap(college)},
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) =>
                        const Center(child: Text('Failed to fetch campus')),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
