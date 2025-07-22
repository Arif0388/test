import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/club/select_a_club.dart';
import 'package:learningx_flutter_app/Screens/event/form/event_form_page.dart';
import 'package:learningx_flutter_app/Screens/fest/select_a_fest.dart';
import 'package:learningx_flutter_app/api/provider/college_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectAPage extends ConsumerStatefulWidget {
  const SelectAPage({super.key});
  @override
  ConsumerState<SelectAPage> createState() => _SelectAPageState();
}

class _SelectAPageState extends ConsumerState<SelectAPage> {
  String _currentUserId = "";
  String _collegeId = "";
  var isAdmin = false;

  @override
  void initState() {
    _loadCurrentUser();
    super.initState();
  }

  _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString("id") ?? "";
      _collegeId = prefs.getString("college") ?? "";
    });
    ref
        .watch(selectedCollegeProvider(_collegeId).notifier)
        .fetchCollege(_collegeId);
  }

  @override
  Widget build(BuildContext context) {
    final collegeData = ref.watch(selectedCollegeProvider(_collegeId));

    setState(() {
      isAdmin = collegeData.admin.any((item) => item.id == _currentUserId);
    });

    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 211, 232, 255),
          titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
          title: const Text("Select a Page"),
        ),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            const Text(
              "Where do you want to host Event",
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            if (isAdmin)
              _buildPageCard(Icons.account_balance_outlined, "On Campus Page",
                  EventFormPage(formData: {"collegeId": _collegeId})),
            _buildPageCard(Icons.festival_outlined, "On Fest Page", const SelectAFest()),
            _buildPageCard(Icons.groups, "On Club Page",
                const SelectAClub(isWorkshop: false))
          ]),
        ));
  }

  Widget _buildPageCard(IconData icon, String title, Widget page) {
    return GestureDetector(
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
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
        ));
  }
}
