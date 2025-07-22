import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/college/college_form.dart';
import 'package:learningx_flutter_app/Screens/college/college_selection_search.dart';

class EmptyCollegeSelected extends ConsumerStatefulWidget {
  const EmptyCollegeSelected({super.key});
  @override
  ConsumerState<EmptyCollegeSelected> createState() =>
      _EmptyCollegeSelectedState();
}

class _EmptyCollegeSelectedState extends ConsumerState<EmptyCollegeSelected> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 64),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "You must select a campus",
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Select your campus",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const CollegeSelectionWidget(
                                    map: {},
                                  )),
                        );
                      },
                      child: _buildCategoryCard(
                          Icons.account_balance_outlined, "Select Campus")),
                  const SizedBox(height: 20.0),
                  const Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey,
                          thickness: 2.0,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'or, if not found',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey,
                          thickness: 2.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    "Create your campus page",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                      onTap: () {
                        Map<String, dynamic> map = HashMap();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CollegeFormActivity(
                                      signupData: map,
                                    )));
                      },
                      child: _buildCategoryCard(
                          Icons.school_outlined, "Create Campus Page")),
                ])));
  }

  Widget _buildCategoryCard(IconData icon, String title) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
        height: 80, // Set the desired height of the card
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(icon, size: 24, color: Colors.black),
            ),
            const SizedBox(width: 16), // Space between icon and text
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
