import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/club/form/club_form1.dart';
import 'package:learningx_flutter_app/Screens/event/form/club_workshop_form.dart';
import 'package:learningx_flutter_app/Screens/event/form/event_form_page.dart';
import 'package:learningx_flutter_app/api/model/club_model.dart';
import 'package:learningx_flutter_app/api/provider/club_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectAClub extends ConsumerStatefulWidget {
  final bool isWorkshop;
  const SelectAClub({super.key, required this.isWorkshop});
  @override
  ConsumerState<SelectAClub> createState() => _SelectAClubState();
}

class _SelectAClubState extends ConsumerState<SelectAClub> {
  String _currentUserId = "";

  @override
  void initState() {
    _loadCurrentUser();
    super.initState();
  }

  _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString("id") ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final clubsAsyncValue = ref.watch(clubProvider("?admin=$_currentUserId"));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
        title: const Text("Select a Club"),
      ),
      body: clubsAsyncValue.when(
        data: (data) {
          return data.isEmpty
              ? Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 64),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "You must be admin of atleast one Club",
                          style: TextStyle(fontSize: 15, color: Colors.blue),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Create your own club",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ClubForm1Activity()),
                              );
                            },
                            child:
                                _buildCategoryCard(Icons.add, "Create a Club")),
                      ]))
              : ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    ClubItem clubItem = data[index];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          clubItem.clubImg,
                          width: 40.0,
                          height: 40.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Row(
                        children: [
                          Flexible(
                              child: Text(
                            clubItem.clubName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          )),
                          const SizedBox(width: 8),
                          if (clubItem.collegeStatus == "verified")
                            const Icon(
                              Icons.verified_outlined,
                              size: 15,
                              color: Colors.blue,
                            ),
                        ],
                      ),
                      subtitle: Text("${clubItem.members.length} members"),
                      onTap: () {
                        Navigator.pop(context);
                        Map<String, String> formData = HashMap();
                        formData['clubId'] = clubItem.id;
                        if (clubItem.college != null &&
                            clubItem.collegeStatus != "rejected") {
                          formData['collegeId'] = clubItem.college!.id;
                        }
                        if (widget.isWorkshop) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ClubWorkshopForm(formData: formData)),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    EventFormPage(formData: formData)),
                          );
                        }
                      },
                    );
                  },
                );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            const Center(child: Text('Failed to fetch clubs')),
      ),
    );
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
