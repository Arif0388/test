import 'package:flutter/material.dart';
import 'package:learningx_flutter_app/Screens/club/select_a_club.dart';
import 'package:learningx_flutter_app/Screens/event/select_a_page.dart';

class EmptyEventFeed extends StatelessWidget {
  const EmptyEventFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
                child: Image.asset(
              "assets/images/new_event.jpeg",
              width: 150,
            )),
            const Text(
              "See your events here!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Column(
                children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SelectAPage()),
                        );
                      },
                      child: _buildCategoryCard(Icons.event_available,
                          "Host Event", "Create an Event")),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SelectAClub(isWorkshop: true,)),
                        );
                      },
                      child: _buildCategoryCard(Icons.work_history,
                          "Club Workshop", "Create a Session for a club")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(IconData icon, String title, String subtitle) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
        height: 100, // Set the desired height of the card
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(20),
              child: Icon(icon, size: 24, color: Colors.black),
            ),
            const SizedBox(width: 16), // Space between icon and text
            Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center vertically
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  const SizedBox(height: 4), // Small gap between text lines
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
